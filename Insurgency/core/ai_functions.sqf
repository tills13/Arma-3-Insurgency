// unit pools
INS_ai_patrol = compile preprocessfile "insurgency\modules\ai\INS_ai_unitPatrol.sqf";

infantryPool = ["O_SoldierU_SL_F", "O_soldierU_repair_F", "O_soldierU_medic_F", "O_sniper_F", "O_Soldier_A_F", "O_Soldier_AA_F", "O_Soldier_AAA_F", "O_Soldier_AAR_F", "O_Soldier_AAT_F", "O_Soldier_AR_F", "O_Soldier_AT_F", "O_soldier_exp_F", "O_Soldier_F", "O_engineer_F", "O_engineer_U_F", "O_medic_F", "O_recon_exp_F", "O_recon_F", "O_recon_JTAC_F", "O_recon_LAT_F", "O_recon_M_F", "O_recon_medic_F", "O_recon_TL_F"];	
armoredPool = ["O_APC_Tracked_02_AA_F", "O_APC_Tracked_02_cannon_F", "O_APC_Wheeled_02_rcws_F", "O_MBT_02_arty_F", "O_MBT_02_cannon_F"];
motorPool =	["O_Truck_02_covered_F", "O_Truck_02_transport_F", "O_MRAP_02_F", "O_MRAP_02_gmg_F", "O_MRAP_02_hmg_F", "O_Truck_02_medical_F"];
attackChopperPool =	["O_Heli_Attack_02_black_F", "O_Heli_Attack_02_F"];
transportChopperPool = ["O_Heli_Light_02_F", "O_Heli_Light_02_unarmed_F"];
uavPool = ["O_UAV_01_F", "O_UAV_02_CAS_F", "O_UGV_01_rcws_F"];
staticPool = ["O_Mortar_01_F", "O_static_AT_F", "O_static_AA_F"];
shipPool = ["O_Boat_Armed_01_hmg_F", "O_Boat_Transport_01_F"];
diverPool =	["O_diver_exp_F", "O_diver_F", "O_diver_TL_F"];
crewPool = ["O_crew_F"];
heliCrewPool =	["O_helicrew_F", "O_helipilot_F"];
unitRanks = ["PRIVATE", "CORPORAL", "SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"];

INS_fn_getRankModifier = {
	_rank = _this;

	for "_i" from 0 to count unitRanks - 1 do { if (_rank == (unitRanks select _i)) exitWith { _rank = _i }; };

	diag_log format["modifier: %1", _rank];
	_rank
};

INS_fn_spawnUnit = {
	_type = if (isNil {_this select 0}) then { infantryPool call BIS_fnc_selectRandom; } else { _this select 0; };
	_group = _this select 1;
	_position = _this select 2;
	_markers = _this select 3;
	_placement = _this select 4;
	_special = _this select 5;

	_unit = _group createUnit [_type, _position, _markers, _placement, _special];
	_position call INS_fn_addMarkerIfNotAlready;
	_unit call INS_fn_initAIUnit;
	_unit	
};

// todo: check for water as position
INS_fn_spawnGroup = {
	_size = _this select 0;
	_position = _this select 1;

	_group = createGroup east;

	for "_i" from 0 to (_size - 1) do {
		_unit = [nil, _group, _position, [], 4, "FORM"] call INS_fn_spawnUnit;
	};

	_group spawn INS_ai_patrol;
	_group
};

INS_fn_fillVehicleSeats = {
	_vehicle = _this select 0;
	_crew = _this select 1;

	_emptySeats = _vehicle emptyPositions "cargo";
	_seatsToFill = if (_crew == -1) then { ((random _emptySeats) + 2) } else { _crew };

	_group = [_seatsToFill, getPos _vehicle] call INS_fn_spawnGroup;
	_vehicle setVariable ["group", _group];
	{ _x moveincargo _vehicle } forEach (units _group);
};

INS_fn_spawnVehicle = {
	private ["_crew"];
	_type = if (isNil {_this select 0}) then { motorPool call BIS_fnc_selectRandom; } else { _this select 0; };
	_position = _this select 1;
	_markers = _this select 2;
	_placement = _this select 3;
	_special = _this select 4;
	_crew = if ((count _this) > 5) then { _this select 5; } else { -1; };

	_vehicle = createVehicle [_type, _position, _markers, _placement, _special];
	_position call INS_fn_addMarkerIfNotAlready;
	[_vehicle, _crew] call INS_fn_fillVehicleSeats;

	_vehicle
};

INS_fn_cacheHousePatrols = {
	_hpatrols = _this;
	_hpgroups = [];

	{
		_alive = { alive _x } count units _x;
		if (_alive != 0) then { 
			_hpgroups = _hpgroups + [[_alive, getPos leader _x]]; 
			{ deleteVehicle _x } forEach units _x;
		};
	} forEach _hpatrols;

	_hpgroups
};

// todo: make them patrol
INS_fn_spawnHousePatrols = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
	_areaRad = _this select 2;

	_groups = [];
	_buildings = [_areaPos, _areaRad] call SL_fnc_findBuildings;
	for "_i" from 0 to (round ((count _buildings) * 0.50)) do {
		_building = _buildings call BIS_fnc_selectRandom;

		_buildingPositions = [_building] call getRandomBuildingPosition;
		_pos = _buildingPositions select (floor(random count _buildingPositions));
		_gridPos = getPos _building call gridPos;

		if (getMarkerColor str _gridPos == "ColorRed") then {
			_eCount = count nearestObjects[_pos, ["Man", "CAR"], 100];
			if (_eCount < 5) then {
				_mGroup = [2, _pos] call INS_fn_spawnGroup;
				_groups = _groups + [_mGroup];
			};
		};
	};

	diag_log format["spawned %1 hps: %2", count _groups, _groups];
	_groups
};

// todo: make them patrol
INS_fn_spawnHousePatrolsCached = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_hpcache = _this select 0;
	_groups = [];

	{
		diag_log str _x;
		_groupSize = _x select 0;
		_position = _x select 1;

		_group = [_groupSize, _position] call INS_fn_spawnGroup;
		_groups = _groups + [_group];
	} forEach _hpcache;

	_groups
};

INS_fn_cacheAreaPatrols = {
	_apatrols = _this;
	_apgroups = [];

	{
		_alive = { alive _x } count units _x;
		if (_alive != 0) then { 
			_apgroups = _apgroups + [[_alive, getPos leader _x]]; 
			{ deleteVehicle _x } forEach units _x;
		};
	} forEach _apatrols;

	_apgroups
};

INS_fn_spawnAreaPatrols = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
	_areaRad = _this select 2;

	_groups = [];

	for "_i" from 0 to ((random 3) + 1) do {
		_spawnPos = [_areaPos, 0, _areaRad, 0, 1, 20, 0] call BIS_fnc_findSafePos;
		_spawnPos = _spawnPos call gridPos;

		if (getMarkerColor str _spawnPos == "ColorRed") then {
			_eCount = count nearestObjects[_spawnPos, ["Man", "CAR"], 100];
			if (_eCount < 5) then {
				_mGroup = [(random 4) + 1, _spawnPos] call INS_fn_spawnGroup;
				_groups = _groups + [_mGroup];
			};
		};
	};

	diag_log format["spawned %1 aps: %2", count _groups, _groups];
	_groups
};

// todo: make them patrol
INS_fn_spawnAreaPatrolsCached = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_apcache = _this select 0;
	_groups = [];

	{
		diag_log str _x;
		_groupSize = _x select 0;
		_position = _x select 1;

		_group = [_groupSize, _position] call INS_fn_spawnGroup;
		_groups = _groups + [_group];
	} forEach _apcache;

	_groups
};

// todo: figure this shit out
// use _vehicle setVariable to store the units associated with this veh.
INS_fn_cacheLightVehicles = {
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

// todo: cache group with vehicle... right now we're just returning the vehicle
// todo: make the vehicles patrol psuedo-randomly
INS_fn_spawnLightVehicles = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
	_areaRad = _this select 2;

	_vehicles = [];

	for "_i" from 0 to (random 1) do {
		_spawnPos = [_areaPos, 0, _areaRad, 0, 1, 20, 0] call BIS_fnc_findSafePos;
		_vehicle = [nil, _spawnPos, [], 5, "None"] call INS_fn_spawnVehicle;
		_vehicles = _vehicles + [_vehicle];
	};

	diag_log format["spawned %1 lvs: %2", count _vehicles, _vehicles];
	_vehicles
};

// todo: make them patrol
INS_fn_spawnLightVehiclesCached = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_lvcache = _this select 0;
	_vehicles = [];

	{
		diag_log str _x;
		_crew = _x select 0;
		_type = _x select 1;
		_pos = _x select 2;

		_vehicle = [_type, _pos, [], 5, "None", _crew] call INS_fn_spawnVehicle;
		_vehicles = _vehicles + [_vehicle];
	} forEach _lvcache;

	_vehicles
};

// todo: figure this shit out
// use _vehicle setVariable to store the units associated with this veh.
INS_fn_cacheStaticPlacements = {
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

// todo: ... do units enter the static placement?
INS_fn_spawnStaticUnits = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
	_areaRad = _this select 2;

	_statics = [];

	for "_i" from 0 to (random 1) do {
		_spawnPos = [_areaPos, 0, _areaRad, 0, 1, 20, 0] call BIS_fnc_findSafePos;
		_static = [(staticPool call BIS_fnc_selectRandom), _spawnPos, [], 5, "None"] call INS_fn_spawnVehicle;
		_statics = _statics + [_static];
	};

	diag_log format["spawned %1 sps: %2", count _statics, _statics];
	_statics
};

INS_fn_spawnStaticUnitsCached = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_spcache = _this select 0;
	_statics = [];

	{	
		diag_log str _x;
		_crew = _x select 0;
		_type = _x select 1;
		_pos = _x select 2;

		_static = [_type, _pos, [], 5, "None", _crew] call INS_fn_spawnVehicle;
		_statics = _statics + [_static];
	} forEach _spcache;

	_statics
};

INS_fn_spawnGroundReinforcements = {
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
};

INS_fn_spawnAirReinforcements = {
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
};

INS_fn_spawnWaterReinforcements = {
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
};

INS_fn_getAIArray = {
    _array = _this;

    _aiPlayerList = [];

    { 
    	if (!(isPlayer _x)) then { _aiPlayerList = _aiPlayerList + [_x]; };
	} forEach _array;

    _aiPlayerList;
};

INS_fn_getAIinGroup = {
    _group = _this;

    _aiPlayerList = [];

    { 
    	if (!(isPlayer _x)) then { _aiPlayerList = _aiPlayerList + [_x]; };
	} forEach units _group;

    _aiPlayerList;
};

INS_fn_dismissAIFromGroup = {
	_group = _this;

	{
		deleteVehicle _x;
	} forEach (_group call INS_fn_getAIinGroup);
};

INS_fn_initAIUnit = {
	//if (isNil "INS_AI_onKilledListener") then { INS_AI_onKilledListener = compile preprocessFile "insurgency\modules\ai\INS_fnc_onDeathListener.sqf" };
	_unit = _this; // test if kind of group or unit

	_unit setSkill ['aimingAccuracy', 0.5];
	_unit setSkill ['aimingShake', 0.5];
	_unit setSkill ['aimingSpeed', 0.5];
	_unit setSkill ['spotDistance', 0.5];
	_unit setSkill ['spotTime', 0.5];
	_unit setSkill ['courage', 0.5];
	_unit setSkill ['reloadSpeed', 0.5];
	_unit setSkill ['commanding', 0.5];
	_unit setSkill ['general', 0.5];

	if (side _unit == east) then { _handle = _unit execVM "insurgency\modules\ai\INS_fnc_onDeathListener.sqf"; };
};

INS_fn_spawnUnits = {
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
	_areaRad = _this select 2;

	if (!isNil {missionNamespace getVariable _areaClassName}) then {
		diag_log format ["spawning cached units in %1", _areaClassName];

		_cachedEnemies = missionNamespace getVariable _areaClassName;
		{
			_type = _x select 0;
			_pos = _x select 1;
			_damage = _x select 2;
			_group = _x select 3;
			_type createUnit [_pos, _group];
			//[_group] call INS_fn_initAIUnit;

			diag_log format ["spawning %1 at %2", _type, _pos];
		} forEach _cachedEnemies;
	} else {
		diag_log format ["spawning units in %1", _areaClassName];
		_buildings = [_areaPos, _areaRad + 40] call SL_fnc_findBuildings;

		{
			_building = _x;
			_buildingPositions = [_building] call getRandomBuildingPosition;
			_pos = _buildingPositions select (floor(random count _buildingPositions));
			_gridPos = getPos _building call gridPos;

			if (getMarkerColor str _gridPos == "ColorRed") then {
				_eCount = count nearestObjects[_pos, ["Man", "CAR"], 15];
				if (_eCount < 5) then {
					//_m = createMarker [format ["box%1", random 1000], getposATL _building];
					//_m setMarkerText str floor random 1;
		            //_m setMarkerShape "ICON"; 
		           	//_m setMarkerType "mil_dot";
		            //_m setMarkerColor "ColorRed";
		            
		            _group = createGroup east;
		            "O_SoldierU_SL_F" createUnit [_pos, _group];
		            //[_group] call INS_fn_initAIUnit;
				};
			};
		} forEach _buildings;
	};
};

INS_fn_despawnUnits = {
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
	_areaRad = _this select 2;
	diag_log format ["deleting units in %1", _areaClassName];

	_enemies = nearestObjects[_areaPos, ["Man", "Car"], _areaRad + 50];
	_cachedEnemies = [];

	{
		if (alive _x) then {
			if (_x isKindOf "Car") then {
				//if (side )
			};
			_eInfo = [typeOf _x, getPos _x, damage _x, group _x];
			deleteVehicle _x;
			diag_log format ["caching %1 at %2", typeOf _x, getPos _x];
			_cachedEnemies = _cachedEnemies + [_eInfo];
		};
		
	} forEach _enemies;

	diag_log str _cachedEnemies;
	missionNamespace setVariable [_areaClassName, _cachedEnemies];
};