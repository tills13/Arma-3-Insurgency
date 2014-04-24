// unit pools

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
	_unit call INS_fn_initAIUnit;
	_unit	
};

// todo: check for water as position
INS_fn_spawnGroup = {
	_size = _this select 0;
	_position = _this select 1;

	_group = createGroup east;

	_mGroup = [];
	for "_i" from 0 to _size do {
		_unit = [nil, _group, _position, [], 4, "FORM"] call INS_fn_spawnUnit;
		_mGroup = _mGroup + [_unit];
	};

	_mGroup
};

INS_fn_fillVehicleSeats = {
	_vehicle = _this;
	_emptySeats = _vehicle emptyPositions "cargo";

	_group = [(random _emptySeats) + 2, getPos _vehicle] call INS_fn_spawnGroup;
	{ _x moveincargo _vehicle } forEach units _group;
};

INS_fn_spawnVehicle = {
	_type = if (isNil {_this select 0}) then { (motorPool + armoredPool) call BIS_fnc_selectRandom; } else { _this select 0; };
	_position = _this select 1;
	_markers = _this select 2;
	_placement = _this select 3;
	_special = _this select 4;

	_vehicle = createVehicle [_type, _position, _markers, _placement, _special];
	_vehicle call INS_fn_fillVehicleSeats;

	_vehicle
};

INS_fn_cacheHousePatrols = {
	_hpatrols = _this;
	_hpgroups = [];

	{
		_numUnits = { alive _x } count units _x;
		_hpgroups = _hpgroups + [_numUnits];
	} forEach _hpatrols;

	_hpgroups
};

// todo: make them patrol
INS_fn_spawnHousePatrols = {
	private ["_group", "_units", "_cityName", "_cityPos", "_cityRad"];
	_cityName = _this select 0;
	_cityPos = _this select 1;
	_cityRad = _this select 2;

	_groups = [];

	{
		_building = _x;
		_buildingPositions = [_building] call getRandomBuildingPosition;
		_pos = _buildingPositions select (floor(random count _buildingPositions));
		_gridPos = getPos _building call gridPos;

		if (getMarkerColor str _gridPos == "ColorRed") then {
			_eCount = count nearestObjects[_pos, ["Man", "CAR"], 15];
			if (_eCount < 5) then {
				_mGroup = [(random 3) + 1, _pos] call INS_fn_spawnGroup;
				_groups = _groups + [_mGroup];
			};
		};
	} forEach ([_cityPos, _cityRad + 40] call SL_fnc_findBuildings);

	_groups
};

// todo: make them patrol
INS_fn_spawnHousePatrolsCached = {
	private ["_group", "_units", "_cityName", "_cityPos", "_cityRad"];
	_cityName = _this select 0;
	_cityPos = _this select 1;
	_cityRad = _this select 2;

	
};

INS_fn_cacheAreaPatrols = {
	_apatrols = _this;
	_apgroups = [];

	{
		_numUnits = { alive _x } count units _x;
		_hpgroups = _hpgroups + [_numUnits];
	} forEach _apatrols;

	_apgroups
};

INS_fn_spawnAreaPatrols = {
	private ["_group", "_units", "_cityName", "_cityPos", "_cityRad"];
	_cityName = _this select 0;
	_cityPos = _this select 1;
	_cityRad = _this select 2;

	_groups = [];

	for "_i" from 0 to ((random 3) + 1) do {
		_spawnPos = [_cityPos, 0, _cityRad, 0, 1, 20, 0] call BIS_fnc_findSafePos;
		_mGroup = [(random 5) + 1, _spawnPos] call INS_fn_spawnGroup;
		_groups = _groups + [_mGroup];
	};

	_groups
};

// todo: figure this shit out
INS_fn_cacheLightVehicles = {
	_lvatrols = _this;
	_lvgroups = [];

	{
		_numUnits = { alive _x } count units _x;
		_lvgroups = _lvgroups + [_numUnits];
	} forEach _lvatrols;

	_lvgroups
};

// todo: cache group with vehicle... right now we're just returning the vehicle
// todo: make the vehicles patrol psuedo-randomly
INS_fn_spawnLightVehicles = {
	private ["_group", "_units", "_cityName", "_cityPos", "_cityRad"];
	_cityName = _this select 0;
	_cityPos = _this select 1;
	_cityRad = _this select 2;

	_vehicles = [];

	for "_i" from 0 to ((random 1) + 1) do {
		_spawnPos = [_cityPos, 0, _cityRad, 0, 1, 20, 0] call BIS_fnc_findSafePos;
		_vehicle = [nil, _spawnPos, [], 5, "None"] call INS_fn_spawnVehicle;
		_vehicles = _vehicles + [_vehicle];
	};

	_vehicles
};

// todo: figure this shit out
INS_fn_cacheStaticPlacements = {
	_spatrols = _this;
	_spgroups = [];

	{
		_numUnits = { alive _x } count units _x;
		_spgroups = _spgroups + [_numUnits];
	} forEach _spatrols;

	_spgroups
};

// todo: ... do units enter the static placement?
INS_fn_spawnStaticUnits = {
	private ["_group", "_units", "_cityName", "_cityPos", "_cityRad"];
	_cityName = _this select 0;
	_cityPos = _this select 1;
	_cityRad = _this select 2;

	_statics = [];

	for "_i" from 0 to ((random 1) + 1) do {
		_spawnPos = [_cityPos, 0, _cityRad, 0, 1, 20, 0] call BIS_fnc_findSafePos;
		_static = [(staticPool call BIS_fnc_selectRandom), _spawnPos, [], 5, "None"] call INS_fn_spawnVehicle;
		_statics = _statics + [_static];
	};

	_statics
};

INS_fn_spawnGroundReinforcements = {
	_cityName = _this select 0;
	_cityPos = _this select 1;
};

INS_fn_spawnAirReinforcements = {
	_cityName = _this select 0;
	_cityPos = _this select 1;
};

INS_fn_spawnWaterReinforcements = {
	_cityName = _this select 0;
	_cityPos = _this select 1;
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
	_cityName = _this select 0;
	_cityPos = _this select 1;
	_cityRad = _this select 2;

	if (!isNil {missionNamespace getVariable _cityName}) then {
		diag_log format ["spawning cached units in %1", _cityName];

		_cachedEnemies = missionNamespace getVariable _cityName;
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
		diag_log format ["spawning units in %1", _cityName];
		_buildings = [_cityPos, _cityRad + 40] call SL_fnc_findBuildings;

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
	_cityName = _this select 0;
	_cityPos = _this select 1;
	_cityRad = _this select 2;
	diag_log format ["deleting units in %1", _cityName];

	_enemies = nearestObjects[_cityPos, ["Man", "Car"], _cityRad + 50];
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
	missionNamespace setVariable [_cityName, _cachedEnemies];
};