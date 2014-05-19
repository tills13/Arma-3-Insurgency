if (isServer) then {
	_updateTime = 60; // in seconds
	_westRatio = 0.4;
	_eastRatio = 0.4;
	_indRatio = 0.2;
	_totalNumberOfGroups = 6;
	//_spawnDistance = 1000;
	_despawnDistance = 2000;

	INS_ambient_cleanUp = {
		while { true } do {
			_centerPos = playableUnits call BIS_fnc_selectRandom;

			{
				_group = _x select 1;
				switch { _x select 0 } do {
					case "INFANTRY": { if ((leader _group) distance _centerPos > _despawnDistance) then { { deleteVehicle _x } forEach group _group; }; };
					case "VEHICLE": { if (_group distance _centerPos > _despawnDistance) then { { deleteVehicle _group } forEach group (_group select 1); deleteVehicle _group; }; };
					case "HELO": { if (_group distance _centerPos > _despawnDistance) then { { deleteVehicle _group } forEach group (_group select 1); deleteVehicle _group; }; };
				};
			} forEach INS_ambient_activeGroups;

			sleep 5;
		};
	};

	INS_ambient_activeGroups = [];
	[_despawnDistance] spawn INS_ambient_cleanUp; // clean up function 

	while { true } then {
		sleep _updateTime;
		_centerPos = playableUnits call BIS_fnc_selectRandom;
		_position = [_centerPos, _spawnDistance, (_spawnDistance * 1.5), 0, 1, 20, 0] call BIS_fnc_findSafePos;

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

		if (random 10 > 3) then { _group = [random 10, _position, _side] call INS_fnc_spawnGroup; _type = "INFANTRY"; } // land
		else {
			if (random 10 > 3) then { _group = [nil, _position, [], 0, "None"] call INS_fnc_spawnVehicle; _type = "VEHICLE"; } // land/water vehicle
			else {
				_subtype = if (random 10 > 5) then { 1; } else { 0; };
				_helo = [nil, _subtype, _position, [], "FLYING"] call INS_fnc_spawnHelicopter;
				_helipadPos = [_centerPos, 1000, 1500, 0, 1, 20, 0] call BIS_fnc_findSafePos;
				_helipad = createVehicle ["Land_HelipadEmpty_F", _helipadPos, [], 0, "None"];

				_wp = _helo addWaypoint [_helipad, 0];
				_wp setWaypointBehaviour "AWARE";
				_wp setWaypointBehaviour "AWARE";
				_wp setWaypointType "UNLOAD";

				_group = _helo;
				_type = "HELO";
			};
		};

		INS_ambient_activeGroups = INS_ambient_activeGroups + [_type, _group];
	};
};