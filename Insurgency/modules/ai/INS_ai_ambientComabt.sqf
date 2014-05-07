if (isServer) then {
	INS_ambient_cleanUp = {
		{
			{

			} forEach 
		} forEach playableUnits;
	};

	_updateTime = 60; // in seconds
	_westGroupCount = 5;
	_westArmoredGroups = 2;
	_eastGroupCount = 5; 
	_eastArmoredGroups = 2;
	_despawnDistance = 2000;

	while { true } then {
		sleep _updateTime;
		_playableUnits = playableUnits;
		_centerPos = _playableUnits call BIS_fnc_selectRandom;

		if (count INS_ambient_westGroups < _westGroupCount) then {
			_spawnPos = [_centerPos, 0, 1000, 0, 1, 20, 0] call BIS_fnc_findSafePos;
			
		} else { sleep (_updateTime / 2) };

		if (count INS_ambient_eastGroups < _eastGroupCount) then {
			_spawnPos = [_centerPos, 0, 1000, 0, 1, 20, 0] call BIS_fnc_findSafePos;

		} else { sleep (_updateTime / 2) };
	};
};