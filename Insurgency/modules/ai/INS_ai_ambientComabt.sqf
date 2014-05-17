if (isServer) then {
	INS_ambient_cleanUp = {
		{
			{

			} forEach 
		} forEach playableUnits;
	};

	INS_ambient_spawn = {
		_side = _this select 0;
		_position = _this select 1;

		
	};

	_updateTime = 60; // in seconds
	_westRatio = 0.4;
	_eastRatio = 0.4;
	_indRatio = 0.2;
	_totalNumberOfGroups = 6;
	//_spawnDistance = 1000;
	_despawnDistance = 2000;

	INS_ambient_activeGroups = [];
	[_despawnDistance] spawn INS_ambient_cleanUp; 

	while { true } then {
		sleep _updateTime;
		_playableUnits = playableUnits;
		_centerPos = _playableUnits call BIS_fnc_selectRandom;
		_position = [_centerPos, 1000, 1500, 0, 1, 20, 0] call BIS_fnc_findSafePos;

		_westGroups = {(side _x) == west} count INS_ambient_activeGroups;
		_eastGroups = {(side _x) == east} count INS_ambient_activeGroups;
		_indeGroups = {((side _x) == resistance) or ((side _x) == independent)} count INS_ambient_activeGroups;

		if (_westGroups < (_westRatio * (count _totalNumberOfGroups)) then { _side = west; } 
		else {
			if (_eastGroups < (_eastRatio * (count _totalNumberOfGroups)) then { _side = east; } 
			else {
				if (_indeGroups < (_indRatio * (count _totalNumberOfGroups)) then { _side = independent; } 
				else { _side = [west, east, independent]; call BIS_fnc_selectRandom; };
			};
		};

		[_side, _position] call INS_ambient_spawn;
	};
};