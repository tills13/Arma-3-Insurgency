if (isServer) then {
	_updateTime = 5; // in seconds
	_westRatio = 0.4;
	_eastRatio = 0.4;
	_indRatio = 0.2;
	_totalNumberOfGroups = 1;
	_spawnDistance = 500; // helos spawn at + 1000 and fly in
	_despawnDistance = 1000;
	INS_ambient_cleanUpMutex = true;

	// I don't think this works 
	INS_ambient_cleanUp = {
		_despawnDistance = _this select 0;

		while { true } do {
			private ["_group", "_centerPos"];
			_centerPos = playableUnits call BIS_fnc_selectRandom;

			waitUntil { INS_ambient_cleanUpMutex };
			INS_ambient_cleanUpMutex = false;
			diag_log format["groups: %1", INS_ambient_activeGroups];

			_index = 0;
			{
				private ["_x"];
				_group = _x select 0;
				_type = _x select 1;
				
				diag_log str (leader _group distance _centerPos);
				switch (_type) do {
					case "INFANTRY": { 
						_alive = {alive _x} count units _group;
						_distance = leader _group distance _centerPos;
						if (_distance > _despawnDistance or _alive == 0) then { 
							{ deleteVehicle _x } forEach units _group;
							INS_ambient_activeGroups set [_index, 0];
						};

					}; 

					case "VEHICLE": {
						_crew = _group getVariable "group";
						_alive = {alive _x} count units _group;
						_distance = leader _crew distance _centerPos;

						if (_distance > _despawnDistance or _alive == 0) then { 
							{ deleteVehicle _x } forEach units _crew;
							deleteVehicle _group;

							INS_ambient_activeGroups set [_index, 0];
						};
					};

					case "HELO": {
						_crew = _group getVariable "group";
						_alive = { alive _x } count units _crew;
						_distance = leader _crew distance _centerPos;

						if (_distance > (_despawnDistance + 1000) or _alive == 0) then { 
							{ deleteVehicle _x } forEach units _crew;
							deleteVehicle _group;

							INS_ambient_activeGroups set [_index, 0];
						};
					};

					case "NONE": { INS_ambient_activeGroups set [_index, 0]; }; 
				};

				_index = _index + 1;
			} forEach INS_ambient_activeGroups;
			INS_ambient_activeGroups = INS_ambient_activeGroups - [0];
			INS_ambient_cleanUpMutex = true;

			sleep 5;
		};
	};

	INS_ambient_vehicleToGroup = {
		_vehicle = _this select 0;
		_group = _this select 1;

		waitUntil { INS_ambient_cleanUpMutex };
		INS_ambient_cleanUpMutex = false;

		for "_i" from 0 to (count INS_ambient_activeGroups - 1) do {
			_index = INS_ambient_activeGroups select _i;
			_type = _index select 1;

			if (_type == "HELO" and (_index select 0) == _vehicle) exitWith { INS_ambient_activeGroups set [_i, [_group, "INFANTRY"]] };
		};

		INS_ambient_cleanUpMutex = false;
	};

	INS_ambient_activeGroups = [];
	[_despawnDistance] spawn INS_ambient_cleanUp; // clean up thread 

	while { true } do {
		diag_log "AMBIENT: SLEEPING";
		if (count INS_ambient_activeGroups == _totalNumberOfGroups) then { sleep _updateTime }
		else { sleep _updateTime / 2 };

		if (count INS_ambient_activeGroups < _totalNumberOfGroups) then {
			_centerPos = position (playableUnits call BIS_fnc_selectRandom);
			_position = [_centerPos, _spawnDistance, (_spawnDistance * 1.5), 0, 1, 20, 0] call BIS_fnc_findSafePos;

			waitUntil { INS_ambient_cleanUpMutex };
			INS_ambient_cleanUpMutex = false;
			_westGroups = {(side (_x select 0)) == west} count INS_ambient_activeGroups; 
			_eastGroups = {(side (_x select 0)) == east} count INS_ambient_activeGroups;
			_indeGroups = {((side (_x select 0)) == resistance) or ((side (_x select 0)) == independent)} count INS_ambient_activeGroups;
			diag_log ("AMBIENT: _westGroups = " + str _westGroups);
			diag_log ("AMBIENT: _eastGroups = " + str _eastGroups);
			diag_log ("AMBIENT: _indeGroups = " + str _indeGroups);
			INS_ambient_cleanUpMutex = true;

			_side = west;
			if (_westGroups < (_westRatio * _totalNumberOfGroups)) then { _side = west; }
			else {
				if (_eastGroups < (_eastRatio * _totalNumberOfGroups)) then { _side = east; }
				else {
					if (_indeGroups < (_indRatio * _totalNumberOfGroups)) then { _side = independent; }
					else { _side = [west, east, independent] call BIS_fnc_selectRandom; };
				};
			};
			
			_group = grpNull;
			_type = "NONE";
			if (random 10 > 10) then { _group = [(random 10) max 5, _position, _side] call INS_fnc_spawnGroup; _type = "INFANTRY"; } // land
			else {
				if (random 10 > 10) then { 
					_subtype = if (random 10 > 7) then { 0 } else { 1 }; 
					_group = [nil, _subtype, _side, _position, "None"] call INS_fnc_spawnVehicle; 
					_type = "VEHICLE"; 
				} else {
					_subtype = 0;//if (random 10 > 7) then { 0 } else { 1 }; 
					_position = [_centerPos, (_spawnDistance), (_spawnDistance), 0, 1, 20, 0] call BIS_fnc_findSafePos; // redo pos. because we need it to fly in...
					_helo = [nil, _subtype, west, _position, "FLY"] call INS_fnc_spawnHelicopter;
					_desination = [_centerPos, (_spawnDistance * 0.5), _spawnDistance, 0, 1, 6, 0] call BIS_fnc_findSafePos;
					_helo doMove _desination;

					if (_subtype == 0) then {
						[_helo, _desination, _position] spawn {
							_helo = _this select 0;
							_desination = _this select 1;
							_originalPos = _this select 2;
							_helo_group = _helo getVariable "group";

							waitUntil { _helo distance _desination > 260 };

							doStop _helo;
							_helo land "GET OUT";

							waitUntil { sleep 2; (position _helo) select 2 > 3 };
							{ unassignVehicle _x } forEach _helo_group;

							[_helo, _helo_group] call INS_ambient_vehicleToGroup;

							_helo doMove _originalPos;

							waitUntil { sleep 1; _helo distance _desination > 1000 };
							{ deleteVehicle _x } forEach crew _helo;
							deleteVehicle _helo;
						};

				        _m = createMarker [format ["box%1", random 1000], _desination];
				        _m setMarkerShape "ICON"; 
				        _m setMarkerType "mil_dot";
				        _m setMarkerColor "ColorBlue";
					};
					
					_group = _helo;
					_type = "HELO";
				};
			};

			if (!isNil {_group}) then { INS_ambient_activeGroups = INS_ambient_activeGroups + [[_group, _type]] };
		};
	};
};