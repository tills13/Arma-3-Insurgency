addMarkerForPosition = {
	_pos = _this select 0;
	_markers = _this select 1;

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
	//shk_pos = compile preprocessfile "eos\functions\shk_pos.sqf";
	//shk_fnc_fillhouse = compile preprocessFileLineNumbers "eos\Functions\SHK_buildingpos.sqf";
	//eos_fnc_getunitpool= compile preprocessfilelinenumbers "eos\UnitPools.sqf";
	//call compile preprocessfilelinenumbers "eos\AI_Skill.sqf";
	//onplayerConnected { [] execVM "eos\Functions\EOS_Markers.sqf"; };

	{
		_markers = [];
		_area = _x;
		_areaClassName = _area select 0;
		_areaName = _area select 1;
		_areaPos = _area select 2;
		_areaRad = (_area select 3) max (_area select 4);
		_buildings = [_areaPos, _areaRad] call SL_fnc_findBuildings;

		{
			_building = _x;
			_mpos = (getPos _building) call gridPos;
			if (isNil "_mpos") then {
				if (debugMode == 1) then { diag_log format["error: %1 - %2", _areaName, _building]; };
			} else {
				_mkr = str _mpos;
				if (getMarkerPos _mkr select 0 == 0) then {
					//_nearHouses = [(getPos (_roads select _i)), 100] call SO_fnc_findHouse;
					
					// do something

					_markers = [_mpos, _markers] call INS_fnc_addMarkerForPosition;
				};
			};
		} forEach _buildings;


		_m = createMarker [format ["box%1", random 1000], _areaPos];
        _m setMarkerShape "ELLIPSE";
        _m setMarkerSize [_areaRad, _areaRad];
        _m setMarkerColor "ColorRed";

		_trigger = createTrigger ["EmptyDetector", _areaPos];
		_trigger setTriggerActivation ["west", "present", true];
		_trigger setTriggerArea [_areaRad, _areaRad, 0, false];
		_trigger setTriggerStatements ["this", format["%1 call SL_fnc_createTriggers; %2 execVM 'insurgency\modules\ai\INS_ai_unitHandler.sqf';", _markers, _area], ""];
		missionNamespace setVariable [format["%1_trigger", _areaClassName], _trigger];
	} forEach (call SL_fnc_urbanAreas);
};

