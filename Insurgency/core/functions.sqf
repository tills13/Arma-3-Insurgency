SL_fnc_urbanAreas = {
	private ["_locations","_cityTypes","_randomLoc","_x","_i","_cities"];
	_i = 0;
	_cities = [];

	_locations = configfile >> "CfgWorlds" >> worldName >> "Names";
	_cityTypes = ["NameVillage","NameCity","NameCityCapital"];

	for "_x" from 0 to (count _locations - 1) do {
		_randomLoc = _locations select _x;
		// get city info
		private["_cityName","_cityPos","_cityRadA","_cityRadB","_cityType","_cityAngle"];
		_cityName = getText(_randomLoc >> "name");
		_cityPos = getArray(_randomLoc >> "position");
		_cityRadA = getNumber(_randomLoc >> "radiusA");
		_cityRadB = getNumber(_randomLoc >> "radiusB");
		_cityType = getText(_randomLoc >> "type");
		_cityAngle = getNumber(_randomLoc >> "angle");
		if (_cityType in _cityTypes) then {
			_cities set [_i,[_cityName, _cityPos, _cityRadA, _cityRadB, _cityType, _cityAngle]];
			_i = _i + 1;
		};
	};
	
	_cities
};

SL_fnc_findBuildings = {
	private ["_center","_radius","_buildings"];
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

SL_fnc_createTriggers = {
	private ["_markers","_pos","_trigE"];

	{
		_pos = getMarkerPos _x;
		_trigE = createTrigger ["EmptyDetector", _pos ];
		_trigE setTriggerActivation ["ANY", "PRESENT", false];
		_trigE setTriggerArea [50, 50, 0, true];
		_trigE setTriggerStatements ["{(side _x) == east} count thisList == 0 AND {(side _x) == west } count thisList >= 1", format["""%1"" setMarkerColor ""ColorGreen"";",_x], ""];

	} foreach _this;
};

SO_fnc_randomCity = {

	private ["_randomLoc", "_cityName", "_cityPos", "_cityRadA", "_cityRadB", "_cityType", "_cityAngle", "_cityTypes","_found"];

	_cityName = "";

	// Stuff we need
	_locations = configfile >> "CfgWorlds" >> worldName >> "Names";
	//_cityTypes = ["Name","NameLocal","NameVillage","NameCity","NameCityCapital"];
	_cityTypes = ["NameVillage","NameCity","NameCityCapital"];
	_found = 0;


	while { _found == 0 } do {
			_randomLoc = _locations call BIS_fnc_selectRandom;

			// get city info
			_cityName = getText(_randomLoc >> "name");
			_cityPos = getArray(_randomLoc >> "position");
			_cityRadA = getNumber(_randomLoc >> "radiusA");
			_cityRadB = getNumber(_randomLoc >> "radiusB");
			_cityType = getText(_randomLoc >> "type");
			_cityAngle = getNumber(_randomLoc >> "angle");

		if (_cityType in _cityTypes) then { _found = 1; };
	};

	[_randomLoc, _cityName, _cityPos, _cityRadA, _cityRadB, _cityType, _cityAngle]
};

SO_fnc_findHouse = {
	private ["_found", "_houses", "_house", "_cpos", "_range", "_bpos"];

	_cpos = _this select 0;
	_range = _this select 1;

	_houses = nearestObjects [_cpos, ["house"], _range];
	_houses
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
		
	if(surfaceIsWater [_position select 0,_position select 1]) then
	{
		// handy! http://forums.bistudio.com/showthread.php?93897-selectBestPlaces-(do-it-yourself-documentation)
		_bestPositions = selectbestplaces [[_position select 0,_position select 1],200,"(1 + houses)",10,1];
		
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
	_radius = if(count _this > 1) then {_this select 1} else {100;};
	
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
    private ["_intelItems","_intel","_used","_ID","_cases","_case","_cache"];
	
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
    private ["_i","_sign","_sign2","_radius","_cache","_pos","_mkr","_range","_intelRadius"];
    
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