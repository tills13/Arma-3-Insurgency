INS_ai_patrol = compile preprocessfile "insurgency\modules\ai\INS_ai_unitPatrol.sqf";

INS_fnc_spawnAI = {
	private ["_inc","_pos","_eCount","_wUnits","_wCount","_house","_clear","_gMkr","_houses"];

	if (count (player call dl_fnc_getAIForPlayer) > 25) exitWith {}; 

	_houses = nearestObjects [player, ["HOUSE"], INS_enemySpawnDistance]; // find available houses for spawn posits
	{ if (!([player, _x, 80] call dl_fnc_canSee)) then { _houses = _houses - [_x]; }; } forEach _houses;
	if (count _houses != 0) then {
		{
			if (count (player call dl_fnc_getAIForPlayer) > 25) exitWith {}; 

			_house = _x;
			_mkr = (position _house) call dl_fnc_gridPos;

			if (true or {getMarkerColor str _mkr == "ColorRed"}) then {
				_pos   = getPosATL _house;	
				_eCount = count nearestObjects [_pos, ["Man"], 15];									
				_wUnits = [_pos, INS_enemySafetyRadius] call dl_fnc_countNearestPlayers; 

				if (_eCount == 0 && _wUnits == 0) then { 
					_spawnPos = [_pos, 0, 15, 0, 1, 20, 0] call BIS_fnc_findSafePos; 
					_unit = [nil, call dl_fnc_getAIGroup, _spawnPos, [], 0, "NONE"] call INS_fnc_spawnUnit;
					//diag_log str _unit;
				};
			};
		} forEach _houses;
	};
};

INS_fnc_despawnAI = {
	_aiInGroup = player call dl_fnc_getAIForPlayer;

	for "_i" from 0 to 25 do {
		_unitName = format["%1_ai_%2", name player, _i];
		if (!isNil _unitName) then {
			_unit = call compile _unitName;
			if (!isNull _unit) then {
				if (!alive _unit) then {
					if ([position _unit, INS_enemyDespawnDistance] call dl_fnc_countNearestPlayers == 0) then { diag_log (group _unit); deleteGroup (group _unit); deleteVehicle _unit; };
				} else {
					if (!([_unit, 100] call dl_fnc_canBeSeen)) then {
						diag_log (group _unit); deleteGroup (group _unit); deleteVehicle _unit;
					} else {
						if (([position _unit, INS_enemyDespawnDistance] call dl_fnc_countNearestPlayers) == 0) then {
							_timeToDespawn = missionNamespace getVariable format["%1_despawn_time", _unitName];
							if (isNil "_timeToDespawn") then { missionNamespace setVariable [format["%1_despawn_time", _unitName], time + INS_enemyDespawnTime]; }
							else {
								if (_timeToDespawn > time) then {
									if (debugMode == 1) then { diag_log format["despawning %1 in %2 seconds", _unitName, round (_timeToDespawn - time)]; };
									if (([position _unit, INS_enemyDespawnDistance + 400] call dl_fnc_countNearestPlayers) == 0) then { deleteGroup group _unit; deleteVehicle _unit; };
								} else { diag_log (group _unit); deleteGroup (group _unit); deleteVehicle _unit; };
							};
						};
					};
				};
			};
		};
	};
};

/* INS_fnc_spawnUnit
 * args: [type, group, position, markers, special] */
INS_fnc_spawnUnit = {
	_type = _this select 0;
	_group = _this select 1;
	_position = _this select 2;
	_markers = _this select 3;
	_placement = _this select 4;
	_special = _this select 5;

	//diag_log str _group;

	if (isNil { _type }) then {
		_isWater = surfaceIsWater _position;
		_pool = call compile format["%1_%2", side _group, if (_isWater) then {"divers"} else {"infantry"}];
		_type = _pool call BIS_fnc_selectRandom;
	};

	_unit = _group createUnit [_type, _position, _markers, _placement, _special];
	_unit call INS_fnc_initAIUnit;

	_unit
};

/* INS_fnc_spawnGroup
 * args: [size, position, side] */
INS_fnc_spawnGroup = {
	_size = _this select 0;
	_position = _this select 1;
	_side = _this select 2;
	_group = createGroup _side;

	for "_i" from 0 to (_size - 1) do {
		_unit = [nil, _group, _position, [], 4, "FORM"] call INS_fnc_spawnUnit;
	};

	//_group spawn INS_ai_patrol;
	_group
};

/* INS_fnc_fillVehicleSeats 
 * args: [vehicle object, crew size, side] 
 * crew size -1 for random */
INS_fnc_fillVehicleSeats = {
	_vehicle = _this select 0;
	_size = if (typeName  (_this select 1) == "Array") then { (random 9) max 5 } else { // gonna leave this in just to make sure
		if ((_this select 1) == -1) then { (random 10) max 5 } else { _this select 1 } // should always be this
	};

	//_size = if ((_this select 1) == -1) then { (random 10) max 5 } else { _this select 1 };
	_side = _this select 2;

	_vehPositions = [typeOf _vehicle] call BIS_fnc_vehicleRoles;
	_veh_group = createGroup _side;
	_veh_crew = createGroup _side;

	{
		if (count units _veh_group > _size) exitWith {};

		_currentPosition = _x;
		_pool = call compile format["%1_crews", toLower (str _side)];
		_type = _pool call BIS_fnc_selectRandom;
		_unit = [_type, if (_currentPosition select 0 in ["driver", "turret"]) then { _veh_crew } else { _veh_group }, position _vehicle, [], 5, "CAN_COLLIDE"] call INS_fnc_spawnUnit;	

		if (_currentPosition select 0 == "driver") then {				
			_unit assignAsDriver _vehicle;
			_unit moveInDriver _vehicle;
		} else {
			if (_currentPosition select 0 == "turret") then {
				_unit assignAsGunner _vehicle;
				_unit moveInTurret [_vehicle, _currentPosition select 1];
			} else {
				_unit moveInCargo _vehicle;
			};
		};
	} forEach _vehPositions;

	_vehicle setVariable ["group", _veh_group];
};

/* INS_fnc_spawnHelicopter
 * args: [type, subtype, side, position, special, crew]
 * type: vehicle class (nil for random)
 * subtype: 0 - transport, 1 - attack 
 * crew: optional, not included means random*/
INS_fnc_spawnHelicopter = {
	private ["_crew"];
	_type = _this select 0;
	_subtype = _this select 1;
	_side = _this select 2;
	_position = _this select 3;
	_special = _this select 4;
	_crew = if ((count _this) > 5) then { _this select 5 } else { -1 };

	if (isNil { _type }) then {
		_pool = call compile format["%1_%2Choppers", toLower (str _side), if (_subtype == 0) then {"transport"} else {"attack"}];
		_type = _pool call BIS_fnc_selectRandom;
	};

	_vehicle = createVehicle [_type, _position, [], 5, _special];
	_position call dl_fnc_addGridMarkerIfNotAlready;
	[_vehicle, _crew, _side] call INS_fnc_fillVehicleSeats;
	_vehicle call INS_fnc_initVehicle;

	_vehicle
};

/* INS_fnc_spawnVehicle
 * args: [type, subtype, group, position, special, crew]
 * type: vehicle class (nil for random)
 * subtype: 0 - normal, 1 - armored */
INS_fnc_spawnVehicle = {
	private ["_crew"];
	_type = _this select 0;
	_subtype = _this select 1;
	_side = _this select 2;
	_position = _this select 3;
	_special = _this select 4;
	_crew = if ((count _this) > 5) then { _this select 5 } else { -1 };

	if (isNil { _type }) then {
		_isWater = surfaceIsWater _position;
		_pool = call compile format["%1_%2", toLower (str _side), if (_isWater) then { "boats" } else { if (_subtype == 0) then { "vehicles" } else { "armored" } }];
		_type = _pool call BIS_fnc_selectRandom;
	};

	_vehicle = createVehicle [_type, _position, [], 0, _special];
	_position call dl_fnc_addGridMarkerIfNotAlready;
	[_vehicle, _crew, _side] call INS_fnc_fillVehicleSeats;
	_vehicle call INS_fnc_initVehicle;

	_vehicle
};

/* INS_fnc_cacheInfantry
 * args: infantry array
 * reformats infantry array to cache format */
INS_fnc_cacheInfantry = {
	_infantry = _this;
	_incache = [];

	{
		_alive = { alive _x } count units _x;
		if (_alive != 0) then { 
			_incache = _incache + [[_alive, getPos leader _x]]; 
			{ deleteVehicle _x } forEach units _x;
		};
	} forEach _infantry;

	_incache
};

/* INS_fnc_cacheInfantry
 * args: lightvehicle array
 * reformats lightvehicle array to cache format */
INS_fnc_cacheAllVehicles = {
	_lvatrols = _this;
	_lvgroups = [];

	{
		_group = _x getVariable "group";
		_alive = { alive _x } count units _group;
		if (_alive != 0) then { 
			_lvgroups = _lvgroups + [[_alive, typeOf _x, getPos _x]];
		};

		{ deleteVehicle _x; } forEach units _group;
		if ((damage _x) < 0.5) then { deleteVehicle _x; };
	} forEach _lvatrols;

	_lvgroups
};

// todo: spawn them out of the zone and have them drive in...
// todo: make the vehicles patrol psuedo-randomly
/* INS_fnc_spawnAllVehicles
 * args: [area name (not used), area position, area radius]
 * generates positions and spawns light vehicles */
INS_fnc_spawnAllVehicles = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
	_areaRad = _this select 2;

	_vehicles = [];

	for "_i" from 0 to (random 1) do {
		_spawnPos = [_areaPos, _areaRad, _areaRad + 100, 0, 1, 20, 0] call BIS_fnc_findSafePos; // spawn outside
		_destination = [_areaPos, 0, _areaRad / 2, 0, 1, 20, 0] call BIS_fnc_findSafePos;

		_subtype = if (random 10 > 6) then { 1 } else { 0 };
		_vehicle = [nil, _subtype, east, _spawnPos, "None"] call INS_fnc_spawnVehicle;
		
		_vehicles = _vehicles + [_vehicle]; // match cached format
	};

	_vehicles
};

// todo: make them patrol
/* INS_fnc_spawnAllVehiclesCached
 * args: cached vehicle array
 * spawns all cached vehicles from the array */
INS_fnc_spawnAllVehiclesCached = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_lvcache = _this select 0;
	_vehicles = [];

	{
		_crew = _x select 0;
		_type = _x select 1;
		_pos = _x select 2;

		_vehicle = [_type, 0, east, _pos, "None", _crew] call INS_fnc_spawnVehicle;
		_vehicles = _vehicles + [_vehicle];
	} forEach _lvcache;

	_vehicles
};

// use _vehicle setVariable to store the units associated with this veh.
/* INS_fnc_cacheStaticPlacements
 * args: static placement array
 * reformats static placement array to cache format */
INS_fnc_cacheStaticPlacements = {
	_spatrols = _this;
	_spgroups = [];

	{
		_group = _x getVariable "group";
		_alive = { alive _x } count units _group;
		if (_alive != 0) then { 
			_spgroups = _spgroups + [[_alive, typeOf _x, getPos _x]];
		};

		{ deleteVehicle _x; } forEach units _group;
		if (_alive != 0) then { deleteVehicle _x };
	} forEach _spatrols;

	_spgroups
};

// todo: ... do units enter the static placement?  - no
// todo: add _side param
/* INS_fnc_spawnStaticUnits
 * args: [area name (not used), area position, area radius]
 * generates positions and spawns static positions */
INS_fnc_spawnStaticUnits = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
	_areaRad = _this select 2;

	_statics = [];

	for "_i" from 0 to (random 1) do {
		_spawnPos = [_areaPos, 0, _areaRad, 0, 1, 20, 0] call BIS_fnc_findSafePos;
		_static = [(east_statics call BIS_fnc_selectRandom), 0, east, _spawnPos, "None"] call INS_fnc_spawnVehicle;
		_statics = _statics + [_static];
	};

	_statics
};

/* INS_fnc_spawnStaticUnitsCached
 * args: cached static placement array
 * spawns all cached static placement from the array */
INS_fnc_spawnStaticUnitsCached = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_spcache = _this select 0;
	_statics = [];

	{	
		_crew = _x select 0;
		_type = _x select 1;
		_pos = _x select 2;

		_static = [_type, 0, east, _pos, "None", _crew] call INS_fnc_spawnVehicle;
		_statics = _statics + [_static];
	} forEach _spcache;

	_statics
};

INS_fnc_spawnGroundReinforcements = {
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
};

INS_fnc_spawnAirReinforcements = {
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
};

INS_fnc_spawnWaterReinforcements = {
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
};

// ---------------------------------------
//	helper functions
// ---------------------------------------

dl_fnc_trackPlayerAI = {
	_player = _this;

	while { true } do {
		for "_i" from 0 to 25 do {
			_string = format["%1_ai_%2", name _player, _i];
			deleteMarker _string;

			if (!isNil _string) then {
				_unit = call compile _string;
				if (!isNull _unit and {alive _unit}) then { 
				 	_m = createMarker [format ["%1", _string], position _unit];
			        _m setMarkerShape "ICON"; 
			        _m setMarkerType "mil_dot";
			        _m setMarkerColor "ColorRed";
				};
			};
		};

		sleep 1;
	};
};

/* dl_fnc_getAIArray
 * args: array of units
 * returns: an array of AI units */
dl_fnc_getAIForPlayer = {
	_player = _this;
	_aiPlayerList = [];

	for "_i" from 0 to 25 do {
		_string = format["%1_ai_%2", name _player, _i];
		if (!isNil _string) then {
			_unit = call compile _string;
			if (!isNull _unit and {alive _unit}) then { _aiPlayerList = _aiPlayerList + [_unit]; };
		};
	};

	_aiPlayerList;
};

dl_fnc_getNextAINameForPlayer = {
	private ["_unit"];
	_player = _this;
	_result = "";

	for "_i" from 0 to 25 do {
		_string = format["%1_ai_%2", name _player, _i];
		if (isNil _string) exitWith { _result = _string };

		_unit = call compile _string;
		if (isNull _unit) exitWith { _result = _string };
		if (!alive _unit) exitWith { _result = _string };
	};

	_result
};

dl_fnc_getAIGroup = {
	_group = group ((player call dl_fnc_getAIForPlayer) call BIS_fnc_selectRandom);
	if (isNil "_group") then { _group = createGroup east; };

	_group
};

/* dl_fnc_getAIArray
 * args: array of units
 * returns: an array of AI units */
dl_fnc_getAIArray = {
	_array = _this;
	_aiPlayerList = [];

	{ if (!(isPlayer _x)) then { _aiPlayerList = _aiPlayerList + [_x]; }; } forEach _array;

	_aiPlayerList;
};

/* dl_fnc_getAIArray
 * args: group
 * returns: an array of AI units */
dl_fnc_getAIinGroup = {
	_group = _this;
	_aiPlayerList = [];

	{ if (!(isPlayer _x)) then { _aiPlayerList = _aiPlayerList + [_x]; }; } forEach units _group;

	_aiPlayerList;
};

/* dl_fnc_dismissAIFromGroup
 * args: group
 * dismisses all AI from a group */
dl_fnc_dismissAIFromGroup = {
	_group = _this;

	{ deleteVehicle _x; } forEach (_group call dl_fnc_getAIinGroup);
};

/* INS_fnc_onDeathListener
 * args: [unit]
 * spawns an intel item at the unit's position INS_prodOfDrop% of the time */
INS_fnc_onDeathListener = {
	_tempRandom = random 100;

	if (_tempRandom > (100 - INS_probOfDrop) || debugMode == 1) then {
		_unit = _this select 0;
		_pos = position _unit;
		_intel = createVehicle ["Land_Suitcase_F", _pos, [], 0, "CAN_COLLIDE"];
		_intel setVariable ["INTEL_STRENGTH", (rank _unit) call INS_fnc_getRankModifier];

		[_intel] spawn {
			_listen = true;
			_intel = _this select 0;
			_pos = getPos _intel;

			timeSlept = 0;
			while { _listen } do {
				sleep 0.5;
				timeSlept = timeSlept + 0.5;

				if (timeSlept > INS_intelTimeout) then { deleteVehicle _intel; _listen = false; };

				_nearUnits = _pos nearEntities [["CAManBase", "Car"], 2];

				{ 
					if (side _x == west) then {
						["New Intel", "New intel received on the location of an ammo cache. A marker has been added to the map.", true, true] call dl_fnc_hintMP;
						[_intel, "INS_fnc_createIntel", false, false] spawn BIS_fnc_MP;
						deleteVehicle _intel;
						_listen = false;
					}; 
				} forEach _nearUnits;	
			};
		};	
	};
};

/* INS_fnc_initAIUnit
 * args: unit
 * sets up an AI unit */
INS_fnc_initAIUnit = {
	private ["_unit"];
	_unit = _this;
	
	_unit setSkill ['aimingAccuracy', 0.2];
	_unit setSkill ['aimingShake', 0.5];
	_unit setSkill ['aimingSpeed', 0.2];
	_unit setSkill ['spotDistance', 0.4];
	_unit setSkill ['spotTime', 0.4];
	_unit setSkill ['courage', 0.5];
	_unit setSkill ['reloadSpeed', 0.5];
	_unit setSkill ['commanding', 0.5];
	_unit setSkill ['general', 0.5];

	//diag_log format["spawning %1 %2", player call dl_fnc_getNextAINameForPlayer, _unit];
	call compile format ["%1 = _unit;", player call dl_fnc_getNextAINameForPlayer];
	if (side _unit == east) then { _unit addEventHandler ["Killed", INS_fnc_onDeathListener]; };
};