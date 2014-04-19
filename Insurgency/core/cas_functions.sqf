INS_CAS_pilotTypes = ["B_Pilot_F", "B_helicrew_F"];
INS_CAS_airCraftTypes = ["B_Plane_CAS_01_F", "B_UAV_02_F", "B_UAV_02_CAS_F", "O_Plane_CAS_02_F", "I_Plane_Fighter_03_CAS_F", "I_Plane_Fighter_03_AA_F"]

INS_CAS_trackAircraft = {
	_plane = _this select 0;

	_markerName = format ["track%1",random 99999];
	_marker = createMarker[_markerName, [0, 0, 0]];
	_markerName setMarkerType "mil_triangle";
	_markerName setMarkerColor "ColorBLUFOR";

	while { !isNull _plane && alive _plane } do {
		_markerName setMarkerDir (getDir _plane);
		_markerName setMarkerPos (getPos _plane);
		sleep 0.1;
	};

	deleteMarker _marker;
};

INS_CAS_spawnPilot = {
	_pos = _this select 0;
	_squadron = createGroup west;
	_type = INS_CAS_pilotTypes call BIS_fnc_selectRandom;

	_pilot = _grp createUnit ["B_Pilot_F", _ranPos, [], 0, "FORM"];	
	_pilot	
};

INS_CAS_spawnAircraft = {
	_type = _this select 0;
	_position = _this select 1;
	_target = _this select 2;
	_direction = _this select 3;

	_vehicle = createVehicle [_type, _position, [], 100, "FLY"];
	_vehicle setVectorDir [(_target select 0) - (getPos _vehicle select 0), (_target select 1) - (getPos _vehicle select 1), 0];
	_vehicle spawn INS_CAS_trackAircraft;
};

INS_CAS_casTimeOut = {
	_timeout = _this select 0;
	timeUntilNextCAS = _timeout;

	while { timeUntilNextCAS > 0 } do {		
		timeUntilNextCAS = timeUntilNextCAS - 1; 
		publicVariable "timeUntilNextCAS";
		sleep 1;
	};
};

INS_CAS_homeMissile = {
	private ["_velocityX", "_velocityY", "_velocityZ", "_target"];
	_bomb = _this select 0;
	_target = _this select 1;
	_bombSpeed = 100;

	if (_bomb distance _target > (_bombSpeed / 20)) then {
		_travelTime = (_target distance _bomb) / _bombSpeed;

		_relDirHor = [_bomb, _target] call BIS_fnc_DirTo;
		_bomb setDir _relDirHor;

		_relDirVer = asin ((((getPosASL _bomb) select 2) - ((getPosASL _target) select 2)) / (_target distance _bomb));
		_relDirVer = (_relDirVer * -1);
		[_bomb, _relDirVer, 0] call BIS_fnc_setPitchBank;

		_velocityX = (((getPosASL _target) select 0) - ((getPosASL _bomb) select 0)) / _travelTime;
		_velocityY = (((getPosASL _target) select 1) - ((getPosASL _bomb) select 1)) / _travelTime;
		_velocityZ = (((getPosASL _target) select 2) - ((getPosASL _bomb) select 2)) / _travelTime;
	};

	[_velocityX, _velocityY, _velocityZ]
};

INS_CAS_doCounterMeasure = {
	_plane = _this select 0;

	for "_i" from 1 to 4 do { _bool = _plane fireAtTarget [_plane, "CMFlareLauncher"]; sleep 0.3; };
	sleep 3;
	for "_i" from 1 to 4 do { _bool = _plane fireAtTarget [_plane, "CMFlareLauncher"]; sleep 0.3; };
};