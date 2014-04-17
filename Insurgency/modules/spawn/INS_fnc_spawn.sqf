potentialSpawns = [];

INS_spawn_chooseSpawnPos = {
	_marker = potentialSpawns call BIS_fnc_selectRandom;
	_radius = 50;

	[getMarkerPos _marker, _radius]
};

objectsToMove = ["MHQ", "AHQ", "FLAG"];

INS_spawn_move = {
	_pos = _this select 1;
	_radius = _this select 2;

	{

	} forEach objectsToMove;
};



if (isServer) then {
	_spawnPos = call INS_spawn_findRandomPos;


} else {
	waitUntil { !isNil "spawnPos"; };
};