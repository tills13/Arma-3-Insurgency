if (isServer) then {
	private ["_cargoPool","_emptySeats","_vehicle","_grp","_grpSize"];
	_vehicle = (_this select 0);
	_grpSize = (_this select 1);
	_grp = (_this select 2);
	_faction = (_this select 3);
	_cargoType = (_this select 4);

	_cargoPool = [_faction, _cargoType] call eos_fnc_getunitpool;
	_side = side (leader _grp);
		
	_emptySeats = _vehicle emptyPositions "cargo"; // FILL EMPTY SEATS
	if (debugMode) then { hint format ["%1", _emptySeats]; };

	//GET MIN MAX GROUP
	_grpMin = _grpSize select 0;
	_grpMax = _grpSize select 1;
	_d = _grpMax - _grpMin;				
	_r = floor(random _d);							
	_grpSize = _r + _grpMin;

	
	if (_emptySeats > 0) then { // IF VEHICLE HAS SEATS		
		if 	(_grpSize > _emptySeats) then { _grpSize = _emptySeats };	// LIMIT SEATS TO FILL TO GROUP SIZE				
		if (debugMode) then { hint format ["Seats Filled: %1", _grpSize]; };	

		for "_x" from 1 to _grpSize do {					
			_unit = _cargoPool select (floor(random(count _cargoPool)));
			_unit = _unit createUnit [GETPOS _vehicle, _grp];
		};

		{ _x moveincargo _vehicle } forEach units _grp;
	};			
};
			