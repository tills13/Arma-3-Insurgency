addMarkerForPosition = {
	_pos = _this select 0;
	_globalPos = _this select 1;
	_radius = _this select 2;
	_markers = _this select 3;

	_mkr = str _pos;
	_mkr = createMarkerLocal[_mkr, _pos];
	_mkr setMarkerShapeLocal "RECTANGLE";
	_mkr setMarkerTypeLocal "SOLID";
	_mkr setMarkerSizeLocal [50, 50];
	_mkr setMarkerColor "ColorRed";
	_mkr setMarkerAlphaLocal 0.5;
	_markers = _markers + [_mkr];

	_markers
};

if (isServer) then {
	//eos_zone_init = compile preprocessFileLineNumbers "eos\core\eos_launch.sqf";
	//eos_fnc_spawnvehicle = compile preprocessfilelinenumbers "eos\functions\eos_SpawnVehicle.sqf";
	//eos_fnc_grouphandlers = compile preprocessfilelinenumbers "eos\functions\setSkill.sqf";
	//eos_fnc_findsafepos  =compile preprocessfilelinenumbers "eos\functions\findSafePos.sqf";
	//eos_fnc_spawngroup = compile preprocessfile "eos\functions\infantry_fnc.sqf";
	//eos_fnc_setcargo = compile preprocessfile "eos\functions\cargo_fnc.sqf";
	//eos_fnc_taskpatrol = compile preprocessfile "eos\functions\shk_patrol.sqf";
	//shk_pos = compile preprocessfile "eos\functions\shk_pos.sqf";
	//shk_fnc_fillhouse = compile preprocessFileLineNumbers "eos\Functions\SHK_buildingpos.sqf";
	//eos_fnc_getunitpool= compile preprocessfilelinenumbers "eos\UnitPools.sqf";
	//call compile preprocessfilelinenumbers "eos\AI_Skill.sqf";
	//onplayerConnected { [] execVM "eos\Functions\EOS_Markers.sqf"; };

	{
		_markers = [];
		_city = _x;
		_cityName = _x select 0;
		_cityPos = _x select 1;
		_cityRad = (_x select 2) max (_x select 3);
		//diag_log format["%1 %2 %3", _cityName, _cityPos, _cityRad];

		_roads = (_cityPos nearRoads _cityRad);

		for "_i" from 0 to (count _roads) step 1 do {
			_mpos = (getPos (_roads select _i) call gridPos);
			if (isNil "_mpos") then {
				//if (debugMode == 1) then { diag_log format["error: %1 - %2", _cityName, count _roads]; };
			} else {
				_mkr = str _mpos;
				if (getMarkerPos _mkr select 0 == 0) then {
					//_nearHouses = [(getPos (_roads select _i)), 50] call SO_fnc_findHouse;

					// do something

					_markers = [_mpos, _cityPos, _cityRad, _markers] call addMarkerForPosition;
				};
			};
		};

		_trigE = createTrigger ["EmptyDetector", _cityPos];
		_trigE setTriggerActivation ["west", "present", true];
		_trigE setTriggerArea [_cityRad, _cityRad, 0, false];
		_trigE setTriggerStatements ["this", format["%1 call SL_fnc_createTriggers; %2 call INS_fn_spawnUnits;", _markers, [_cityName, _cityPos, _cityRad]], format["%1 call INS_fn_despawnUnits;", [_cityName, _cityPos, _cityRad]]];
	} forEach (call SL_fnc_urbanAreas);







	/*{
		_cityName = _x select 0;
		_cityPos = _x select 1;
		_cityRadA = _x select 2;

		_numSpawns = 10 max random (_cityRadA / 30);
		_mkr = str _cityName;
		if (getMarkerPos _mkr select 0 == 0) then {
			_marker = format["%1", _cityPos];
			_mkr = createMarker [_marker, _cityPos];
			_mkr setMarkerShape "ELLIPSE";
			_mkr setMarkerType "SOLID";
			_mkr setMarkerSize [_cityRadA, _cityRadA];
			_mkr setMarkerColor "ColorRed";

			//null = [[_mkr], [3, 2], [5, 2], [3, 3], [0, 0], [2, 50], [2, 3, 5], [0, 1, _cityRadA/2, EAST, TRUE, TRUE]] call eos_zone_init;
		};


	} forEach (call SL_fnc_urbanAreas);*/

	//null = [["MAINAIRFIELD"], [3, 2], [6, 2], [3, 3], [2, 50], [3, 75], [2, 2, 75], [0, 1, 500, EAST, TRUE, TRUE]] call eos_zone_init; // EXTREME
	//null = [["MZONE", "MZONE1", "MZONE2", "MZONE3", "MZONEIMP", "EASTPP"], [4, 2], [4, 2], [3, 2], [2, 50], [3, 75], [2, 3, 25], [0, 1, 500, EAST, TRUE, TRUE]] call eos_zone_init; // HARD
	//null = [["NEAIRFIELD", "SAIRFIELD", "AACAIRFIELD", "DESERTAIRFIELD", "MPP", "NISLAND", "MZONE6", "MZONE8", "MZONE9"], [3, 2], [3, 2], [1, 3], [0, 0], [2, 50], [1, 3, 25], [0, 1, 500, EAST, TRUE, TRUE]] call eos_zone_init; // MEDIUM
	//null = [["NAIRFIELD", "DAM", "STADIUM", "SWAMP", "MZONE4", "MZONE7", "ERUINS", "WINDFARM", "MZONE5", "CHAPEL", "PPWEST", "CASTLE", "WINDFARM1", "NORTHTIP"], [2, 1], [3, 1], [0, 0], [0, 0], [1, 50], [0, 0, 0], [0, 1, 500, EAST, TRUE, TRUE]] call eos_zone_init; // EASY
	//null = [["RADIOTOWER", "QUARRY", "MINE", "SLUMS"], [2, 1], [2, 1], [0, 0], [0, 0], [0, 0], [2, 2, 5], [0, 1, 500, EAST, TRUE, TRUE]] call eos_zone_init; // JOKE
};

