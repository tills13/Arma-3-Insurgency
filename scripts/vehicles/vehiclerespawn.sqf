if (!isServer) exitWith {};

_unit = _this select 0;
_unitinit = if (count _this > 1) then { _this select 1 } else { };
_haveinit = if (count _this > 1) then { true } else { false };
_delay = destroyedRespawnDelay;
_deserted = abandonedRespawnDelay;

_hasname = false;
_unitname = vehicleVarName _unit;
if (isNil _unitname) then { _hasname = false; } else { _hasname = true; };
_run = true;

if (_delay < 0) then { _delay = 0 };
if (_deserted < 0) then { _deserted = 0 };

_dir = getDir _unit;
_position = getPosASL _unit;
_type = typeOf _unit;
_dead = false;
_nodelay = false;

while { _run } do {	
	sleep (2 + random 10);
	if ((getDammage _unit > 0.8) && ({alive _x} count crew _unit == 0)) then { _dead = true };

	if (_deserted > 0) then {
		if ((getPosASL _unit distance _position > 10) && ({alive _x} count crew _unit == 0) && (getDammage _unit < 0.8)) then {
			_timeout = time + _deserted;
			sleep 0.1;
			waitUntil { _timeout < time or !alive _unit or { alive _x } count crew _unit > 0 };
			if ({ alive _x } count crew _unit > 0) then { _dead = false }; 
			if ({ alive _x } count crew _unit == 0) then { _dead = true; _nodelay = true }; 
			if !(alive _unit) then { _dead = true; _nodelay = false }; 
		};
	};

	
	if (_dead) then {
		if (_nodelay) then { sleep 0.1; _nodelay = false; } else { sleep _delay; };	
		sleep 0.1;

		deleteVehicle _unit;
		sleep 2;

		_unit = _type createVehicle _position;
		_unit setPosASL _position;
		_unit setDir _dir;


		_init = "";
		if (_hasInit) then { _init = format ["%1; ", _unitinit]; };
		_sCommand = format ["{%1(objectFromNetID '%2') = this; this setVehicleVarName ""%2""}", _init, _unitname];
		[_sCommand, "BIS_fnc_spawn", true, true] spawn BIS_fnc_MP;

		_dead = false;
	};
};