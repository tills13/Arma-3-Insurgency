INS_spawn_chooseSpawnPos = {
	potentialSpawns = [];
	potentialSpawns = potentialSpawns + ["random_spawn"];

	marker = "random_spawn_%1";
	mcount = 1;
	while {(str getMarkerPos format[marker, mcount]) != (str [0, 0, 0])} do {
		potentialSpawns = potentialSpawns + [format[marker, mcount]];
		mcount = mcount + 1;
	};

	_marker = potentialSpawns call BIS_fnc_selectRandom;

	diag_log format ["spawning at %1 (%2)", _marker, getMarkerPos _marker];
	(getMarkerPos _marker)
};

INS_spawn_move = {
	_pos = _this select 0;
	_objectsToMove = _this select 1;
	diag_log str _pos;
	FLAG setPos _pos;

	{
		_mPos = [(position FLAG), 5, 20, 5, 0, 20, 0] call BIS_fnc_findSafePos;
		_x setPos _mPos;
		[_x, _mPos, getDir _x] call INS_veh_updateLocation;
	} forEach _objectsToMove;
};

if (isServer) then {
	waitUntil { !isNil "MHQ" and !isNil "AHQ" and !isNil "FLAG" };
	spawnPos = call INS_spawn_chooseSpawnPos; publicVariable "spawnPos";
	([spawnPos] + [[MHQ, AHQ]]) call INS_spawn_move;
};

if (!isDedicated) then {
	waitUntil { !isNil "spawnPos" };
	player setPos ([(position FLAG), 5, 20, 5, 0, 20, 0] call BIS_fnc_findSafePos);
};