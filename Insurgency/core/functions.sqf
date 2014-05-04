// ---------------------------------------
//	core functions
// ---------------------------------------

INS_prepareZones = {
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
        _m setMarkerSize [_areaRad + 300, _areaRad + 300];
        _m setMarkerColor "ColorRed";

		_trigger = createTrigger ["EmptyDetector", _areaPos];
		_trigger setTriggerActivation ["west", "present", true];
		_trigger setTriggerArea [_areaRad + 300, _areaRad + 300, 0, false];
		//_trigger setTriggerStatements ["this", format["%1 call SL_fnc_createTriggers; %2 execVM 'insurgency\modules\ieds\INS_ieds.sqf';", _markers, _area], ""];
		_trigger setTriggerStatements ["this", format["%1 call SL_fnc_createTriggers; %2 execVM 'insurgency\modules\ai\INS_ai_unitHandler.sqf';", _markers, _area], ""];
		missionNamespace setVariable [format["%1_trigger", _areaClassName], _trigger];
	} forEach (call SL_fnc_urbanAreas);
};

// ---------------------------------------
//	helper functions
// ---------------------------------------

addActionMP = {
	private ["_object", "_title", "_script", "_args", "_showInWindow", "_hideOnUse", "_condition"];

	_object = _this select 0;
	_title = _this select 1;
	_script = _this select 2;
	_args = _this select 3;
	_showInWindow = _this select 4;
	_hideOnUse = _this select 5;
	_condition = _this select 6;

	_object addAction [_title, _script, _args, 1, _showInWindow, _hideOnUse, "", _condition];
};

addActionMPHelper = {
	private ["_object", "_title", "_script", "_args", "_showInWindow", "_hideOnUse", "_condition"];

	_object = _this select 0;
	_title = _this select 1;
	_script = _this select 2;
	_args = _this select 3;
	_showInWindow = _this select 4;
	_hideOnUse = _this select 5;
	_condition = _this select 6;

	[[_object, _title, _script, _args, _showInWindow, _hideOnUse, _condition], "addActionMP", true, true] spawn BIS_fnc_MP;
};

INS_fnc_getCityNameFromPath = {
	_path = _this;
    _array = toArray _path;

    _cityName = [];
    _break = false;
    for "_i" from (count _array - 1) to 0 step -1 do {
        if ((_array select _i) != 47) then { _cityName = [(_array select _i)] + _cityName; }
        else { _break = true; };

        if (_break) exitWith {};
    };

    toString _cityName;
};

SL_fnc_urbanAreas = {
	private ["_locations", "_cityTypes", "_randomLoc", "_x", "_i", "_cities"];
	_i = 0;
	_cities = [];

	_locations = configfile >> "CfgWorlds" >> worldName >> "Names";
	_cityTypes = ["NameVillage", "NameCity", "NameCityCapital", "NameLocal"];

	for "_x" from 0 to (count _locations - 1) do {
		private["_cityName", "_cityPos", "_cityRadA", "_cityRadB", "_cityType", "_cityAngle"];
		_cityClassName = _locations select _x;
		_cityName = getText(_cityClassName >> "name");
		_cityPos = getArray(_cityClassName >> "position");
		_cityRadA = getNumber(_cityClassName >> "radiusA");
		_cityRadB = getNumber(_cityClassName >> "radiusB");
		_cityType = getText(_cityClassName >> "type");
		_cityAngle = getNumber(_cityClassName >> "angle");
		if (_cityType in _cityTypes) then {
			_cities set [_i, [((str _cityClassName) call INS_fnc_getCityNameFromPath), ((str _cityClassName) call INS_fnc_getCityNameFromPath), _cityPos, _cityRadA, _cityRadB, _cityType, _cityAngle]];
			_i = _i + 1;
		};
	};
	
	_cities
};

SL_fnc_findBuildings = {
	private ["_center", "_radius", "_buildings"];
	_center = _this select 0;
	_radius = _this select 1;
	_buildings = nearestObjects [_center, ["house"], _radius];
	_buildings
};

SL_fnc_buildingPositions = {
	private ["_cbpos"];
	_house = _this select 0;
	_cbpos = 0;
	for "_x" from 1 to 100 do {
		if (format ["%1",(_house buildingPos _x)] != "[0,0,0]") then {
			_cbpos = _cbpos + 1;
		};
	};

	_cbpos
};

// todo: make sure the condition works...
SL_fnc_createTriggers = {
	private ["_markers", "_pos", "_trigger"];

	{
		pos = getMarkerPos _x;
		_trigger = createTrigger ["EmptyDetector", pos];
		_trigger setTriggerActivation ["ANY", "PRESENT", false];
		_trigger setTriggerArea [50, 50, 0, true];
		_trigger setTriggerStatements ["", format["
			_curColor = getMarkerColor '%1';

			if ({(side _x) == east} count thisList == 0 and {(side _x) == west } count thisList >= 1) then {
				if (_curColor == 'ColorRed' || _curColor == 'ColorYellow') then { '%1' setMarkerColor 'ColorGreen' };
			};

			if ({(side _x) == east} count thisList >= 1 and {(side _x) == west } count thisList == 0) then {
				if (_curColor == 'ColorGreen') then { '%1' setMarkerColor 'ColorYellow' };
			};
		", _x], ""];
	} foreach _this;
};

SO_fnc_findHouse = {
	private ["_found", "_houses", "_cpos", "_range", "_bpos"];

	_cpos = _this select 0;
	_range = _this select 1;

	_houses = nearestObjects [_cpos, ["house"], _range];
	_houses
};

dl_fnc_velocityToSpeed = {
	_vel = _this;
	_dx = _vel select 0;
	_dy = _vel select 1;
	_dz = _vel select 2;

	_speed = sqrt (_dx * _dx + _dy * _dy + _dz * _dz);
	_speed
};

// ---------------------------------------
//	position functions
// ---------------------------------------

gridPos = {
	_pos = _this;

	_x = _pos select 0;
 	_y = _pos select 1;
 	_x = _x - (_x % 100);
 	_y = _y - (_y % 100);
 	_mpos = [_x + 50, _y + 50, 0];

 	_mpos
};

getRandomRelativePositionLand = {		
	private ["_target", "_distance", "_direction", "_position", "_bestPositions"];
	
	_target = _this select 0;
	_distance = _this select 1;
	
	_direction = random 360;
	_position = [_target, _distance, _direction] call BIS_fnc_relPos;
		
	if(surfaceIsWater [_position select 0,_position select 1]) then {
		// handy! http://forums.bistudio.com/showthread.php?93897-selectBestPlaces-(do-it-yourself-documentation)
		_bestPositions = selectbestplaces [[_position select 0,_position select 1],200, "(1 + houses)",10,1];
		
		_position = _bestPositions select 0;
		_position = _position select 0;
		_position set [count _position, 0];
	};
	
	_position
};

getRandomRelativePositionWater = {		
	private ["_target", "_distance", "_direction", "_position"];
	
	_target = _this select 0;
	_distance = _this select 1;
	
	_direction = random 360;
	_position = [_target, _distance, _direction] call BIS_fnc_relPos;
	
	while {!(surfaceIsWater [_position select 0,_position select 1])} do {
		_direction = random 360;
		_position = [_target, _distance, _direction] call BIS_fnc_relPos;
	};
	
	_position
};

getCountBuildingPositions = {		
	private ["_building", "_count"];
	
	_building = _this select 0;
	_count = 0;
	
	while {str(_building buildingPos _count) != "[0,0,0]"} do 
	{
		_count = _count + 1;
	};
	
	_count
};

getRandomBuildingPosition = {		
	private ["_building", "_count", "_position"];
	
	_building = _this select 0;
	_count = [_building] call getCountBuildingPositions;
	
	if(_count == 0) then {
		_position = getPos _building;
	} else {
		_position = random _count;
		_position = _building buildingPos _position;
	};
	
	if((_position select 0) == 0) then {
		_position = getPos _building;
	};
	
	_position
};

getSideOfRoadPosition = {		
	private ["_target", "_radius", "_roads", "_road", "_position"];
	
	_target = _this select 0;
	_radius = if(count _this > 1) then { _this select 1 } else { 100 };
	
	_roads = _target nearRoads _radius;
		
	if(count _roads > 1) then {
		_road = getPos (_roads select (random((count _roads)-1)));
		_position = [(_road select 0) + 6, _road select 1, _road select 2];
	} else {
		_position = _target;
	};
	
	_position
};

// ---------------------------------------
//	intel functions
// ---------------------------------------

pickedUpIntel = { 
	hint format["New intel received on the location of an ammo cache. A marker has been added to the map."] 	
};

intelPickup = {
    private ["_intelItems", "_intel", "_used", "_ID", "_cases", "_case", "_cache"];
	
	_intelItems = ["Land_Laptop_unfolded_F", "Land_HandyCam_F", "Land_SatellitePhone_F", "Land_SurvivalRadio_F", "Box_East_Ammo_F", "Land_Suitcase_F"];
	_intel = _this select 0;
	_used = _this select 1;
	_ID = _this select 2;
	_intel removeAction _ID;
	
	_cases = nearestObjects[getPos player, _intelItems, 10];
	
	if (count _cases == 0) exitWith {};
	
	_case = _cases select 0;
	
	if isNull _case exitWith {};
	deleteVehicle _case;
	
	_cache = cache;
	
	if (isNil "_cache") exitWith {};

	[nil, "pickedUpIntel", true, false] spawn BIS_fnc_MP;
	[_cache, "createIntel", false, false] spawn BIS_fnc_MP;
};

createIntel = { 
    private ["_i", "_sign", "_sign2", "_radius", "_cache", "_pos", "_mkr", "_range", "_intelRadius"];
    
    _cache = cache;
    _intel = _this;
    _strength = _intel getVariable "INTEL_STRENGTH";
	if (!isNil "_strength") then { _intelRadius = 500 - ((_strength + 1) * 25); }
	else { _intelRadius = 500; };
    _i = 0; 
	
	while { (getMarkerPos format["%1intel%2", _cache, _i] select 0) != 0} do { _i = _i + 1; }; 	
	_sign = 1; 
	
	if (random 100 > 50) then { _sign = -1; };
	_sign2 = 1; 
	
	if (random 100 > 50) then { _sign2 = -1; };
	_radius = _intelRadius - _i * 50;
	if (_radius < 50) then { _radius = 50; };
	
	_pos = [(getPosATL _cache select 0) + _sign * (random _radius), (getPosATL _cache select 1) + _sign2 * (random _radius)];
	_mkr = createMarker[format["%1intel%2", _cache, _i], _pos]; 
	_mkr setMarkerType "hd_unknown";
	_range = round sqrt(_radius ^ 2 * 2);
	_range = _range - (_range % 25);
	_mkr setMarkerText format["%1m", _range];
	_mkr setMarkerColor "ColorRed"; 	
	_mkr setMarkerSize [0.5, 0.5];

	INS_marker_array = INS_marker_array + [_mkr];
};

// ---------------------------------------
//	marker functions
// ---------------------------------------

INS_fnc_addMarkerForPosition = {
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

INS_fn_addMarkerIfNotAlready = {
	_pos = _this;
	_mpos = _pos call gridPos;

	_mkr = str _mpos;
	if (getMarkerPos _mkr select 0 == 0) then {
		_mkr = createMarkerLocal[_mkr, _mpos];
		_mkr setMarkerShapeLocal "RECTANGLE";
		_mkr setMarkerTypeLocal "SOLID";
		_mkr setMarkerSizeLocal [50, 50];
		_mkr setMarkerColor "ColorRed";
		_mkr setMarkerAlphaLocal 0.5;
	};	
};