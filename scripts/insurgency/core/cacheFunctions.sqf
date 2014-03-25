killedText = {
	hint parseText format["<t color='#eaeaea' align='center' size='1.2'>%1/6 ammo caches have been destroyed</t>", INS_west_score]
};

pickedUpIntel = { 
	hint parseText format["<t color='#eaeaea' align='center' size='1.2'>New intel received on the location of an ammo cache. A marker has been added to the map.</t>"] 	
};

cacheKilled = {
	private ["_pos","_x"];
	
	_pos = getPos cache;
	_x = 0;
	
	while { _x <= 20 } do {
		"M_Mo_82mm_AT_LG" createVehicle _pos;
		_x = _x + 1 + random 4;
		sleep 1;
	};
	
	[nil, "killedText", nil, false] spawn BIS_fnc_MP;
};

cacheFake = {
	private ["_pos","_x"];
	
	_pos = getPos cache;
	_x = 0;
	
	while { _x <= 20 } do {
		"M_Mo_82mm_AT_LG" createVehicle _pos;
		_x = _x + 1 + random 4;
		sleep 1;
	};
};

intelPickup = {
    private ["_intelItems","_intel","_used","_ID","_cases","_case","_cache"];
	
	_intelItems = ["Land_Laptop_unfolded_F", "Land_HandyCam_F", "Land_SatellitePhone_F", "Land_SurvivalRadio_F", "Box_East_Ammo_F", "Land_Suitcase_F"];
	_intel = _this select 0;
	_used = _this select 1;
	_ID = _this select 2;
	_intel removeAction _ID;
	
	_cases = nearestObjects[getPos player, _intelItems, 10];
	
	if (count _cases == 0) exitWith { };
	
	_case = _cases select 0;
	
	if isNull _case exitWith { };
	
	deleteVehicle _case;
	player groupChat "You retrieved some INTEL on the general location of an ammo cache";
	
	_cache = cache;
	
	if (isNil "_cache") exitWith { };

	[nil, "pickedUpIntel", true, false] spawn BIS_fnc_MP;
	[_cache, "createIntel", false, false] spawn BIS_fnc_MP;
};

createIntel = { 
    private ["_i","_sign","_sign2","_radius","_cache","_pos","_mkr","_range","_intelRadius"];
    
    _cache = cache;
	_intelRadius = 500;
    _i = 0; 
	
	while { (getMarkerPos format["%1intel%2", _cache, _i] select 0) != 0} do { _i = _i + 1; }; 	
	
	_sign = 1; 
	
	if (random 100 > 50) then { _sign = -1; };
	
	_sign2 = 1; 
	
	if (random 100 > 50) then { _sign2 = -1; };
	
	_radius = _intelRadius - _i * 50;
	
	if (_radius < 50) then { _radius = 50; };
	
	_pos = [(getPosATL _cache select 0) + _sign *(random _radius),(getPosATL _cache select 1) + _sign2*(random _radius)];
	_mkr = createMarker[format["%1intel%2", _cache, _i], _pos]; 
	_mkr setMarkerType "hd_unknown";
	_range = round sqrt(_radius^2*2);
	_range = _range - (_range % 50);
	_mkr setMarkerText format["%1m", _range];
	_mkr setMarkerColor "ColorRed"; 	
	_mkr setMarkerSize [0.5, 0.5];
};

addactionMP = {
	private["_object","_screenMsg"];
	_object = _this select 0;
	_screenMsg = _this select 1;

	if (isNull _object) exitWith { };

	_object addaction [_screenMsg, "call intelPickup"];
};