INS_ai_patrol = compile preprocessfile "insurgency\modules\ai\INS_ai_unitPatrol.sqf";

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

INS_fnc_spawnUnit = {
	_type = if (isNil {_this select 0}) then { infantryPool call BIS_fnc_selectRandom; } else { _this select 0; };
	_group = _this select 1;
	_position = _this select 2;
	_markers = _this select 3;
	_placement = _this select 4;
	_special = _this select 5;

	_unit = _group createUnit [_type, _position, _markers, _placement, _special];
	_position call dl_fnc_addGridMarkerIfNotAlready;
	_unit call INS_fnc_initAIUnit;
	_unit	
};

// todo: check for water as position
INS_fnc_spawnGroup = {
	_size = _this select 0;
	_position = _this select 1;
	_group = createGroup east;

	for "_i" from 0 to (_size - 1) do {
		_unit = [nil, _group, _position, [], 4, "FORM"] call INS_fnc_spawnUnit;
	};

	if (debugMode == 1) then {
        _m = createMarker [format ["box%1", random 1000], _position];
        _m setMarkerShape "ICON"; 
        _m setMarkerType "mil_dot";
        _m setMarkerColor "ColorRed";
	};

	_group spawn INS_ai_patrol;
	_group
};

INS_fnc_fillVehicleSeats = {
	_vehicle = _this select 0;
	_crew = _this select 1;

	_emptySeats = _vehicle emptyPositions "cargo";
	_seatsToFill = if (_crew == -1) then { ((random _emptySeats) + 2) } else { _crew };

	_group = [_seatsToFill, getPos _vehicle] call INS_fnc_spawnGroup;
	_vehicle setVariable ["group", _group];
	{ _x moveincargo _vehicle } forEach (units _group);
};

INS_fnc_spawnVehicle = {
	private ["_crew"];
	_type = if (isNil {_this select 0}) then { motorPool call BIS_fnc_selectRandom; } else { _this select 0; };
	_position = _this select 1;
	_markers = _this select 2;
	_placement = _this select 3;
	_special = _this select 4;
	_crew = if ((count _this) > 5) then { _this select 5; } else { -1; };

	_vehicle = createVehicle [_type, _position, _markers, _placement, _special];
	_position call dl_fnc_addGridMarkerIfNotAlready;
	[_vehicle, _crew] call INS_fnc_fillVehicleSeats;

	_vehicle
};

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

INS_fnc_genInfantryPositions = {
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
		_gridPos = (getPos _building) call dl_fnc_gridPos;

		if (getMarkerColor str _gridPos == "ColorRed") then {
			_eCount = count nearestObjects[_pos, ["Man", "Car"], 100];
			if (_eCount < 5) then { _groups = _groups + [[2, _pos]]; };
		};
	};

	for "_i" from 0 to ((random 3) + 1) do {
		_spawnPos = [_areaPos, 0, _areaRad, 0, 1, 20, 0] call BIS_fnc_findSafePos;

		_spawnPos call dl_fnc_addGridMarkerIfNotAlready;
		_eCount = count nearestObjects[_spawnPos, ["Man", "Car"], 100];
		if (_eCount < 5) then { _groups = _groups + [[round (random 4) + 1, _spawnPos]]; };

	};

	_groups
};

INS_fnc_cacheLightVehicles = {
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

// todo: figure this shit out...
// todo: spawn them out of the zone and have them drive in...
// todo: make the vehicles patrol psuedo-randomly
INS_fnc_spawnLightVehicles = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
	_areaRad = _this select 2;

	_vehicles = [];

	for "_i" from 0 to (random 1) do {
		_spawnPos = [_areaPos, 0, _areaRad, 0, 1, 20, 0] call BIS_fnc_findSafePos;
		_vehicle = [nil, _spawnPos, [], 0, "None"] call INS_fnc_spawnVehicle;
		_vehicles = _vehicles + [_vehicle]; // match cached format
	};

	_vehicles
};

// todo: make them patrol
INS_fnc_spawnLightVehiclesCached = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_lvcache = _this select 0;
	_vehicles = [];

	{
		_crew = _x select 0;
		_type = _x select 1;
		_pos = _x select 2;

		_vehicle = [_type, _pos, [], 5, "None", _crew] call INS_fnc_spawnVehicle;
		_vehicles = _vehicles + [_vehicle];
	} forEach _lvcache;

	_vehicles
};

// todo: figure this shit out
// use _vehicle setVariable to store the units associated with this veh.
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
INS_fnc_spawnStaticUnits = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_areaClassName = _this select 0;
	_areaPos = _this select 1;
	_areaRad = _this select 2;

	_statics = [];

	for "_i" from 0 to (random 1) do {
		_spawnPos = [_areaPos, 0, _areaRad, 0, 1, 20, 0] call BIS_fnc_findSafePos;
		_static = [(staticPool call BIS_fnc_selectRandom), _spawnPos, [], 5, "None"] call INS_fnc_spawnVehicle;
		_statics = _statics + [_static];
	};

	_statics
};

INS_fnc_spawnStaticUnitsCached = {
	private ["_group", "_units", "_areaClassName", "_areaPos", "_areaRad"];
	_spcache = _this select 0;
	_statics = [];

	{	
		_crew = _x select 0;
		_type = _x select 1;
		_pos = _x select 2;

		_static = [_type, _pos, [], 5, "None", _crew] call INS_fnc_spawnVehicle;
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

dl_fnc_getAIArray = {
    _array = _this;

    _aiPlayerList = [];

    { 
    	if (!(isPlayer _x)) then { _aiPlayerList = _aiPlayerList + [_x]; };
	} forEach _array;

    _aiPlayerList;
};

dl_fnc_getAIinGroup = {
    _group = _this;

    _aiPlayerList = [];

    { 
    	if (!(isPlayer _x)) then { _aiPlayerList = _aiPlayerList + [_x]; };
	} forEach units _group;

    _aiPlayerList;
};

dl_fnc_dismissAIFromGroup = {
	_group = _this;

	{
		deleteVehicle _x;
	} forEach (_group call dl_fnc_getAIinGroup);
};

// args: [unit, position]
// returns true if the player has a clear line of sight to that position
// false if not (duh)
dl_fnc_canSee = {
	_unit = _this select 0;
	_position = _this select 1;

	_intersect = [_unit, "VIEW"] intersect [position _unit, _position];
	_result = count _intersect == 0; 
	//diag_log format ["%1, %2", _intersect, _result];
	_result
};

// args: [unit]
// returns true if the player has a clear line of sight to that position
// false if not (duh)
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
						["New intel received on the location of an ammo cache. A marker has been added to the map.", true, true] call dl_fnc_hintMP;
						[_intel, "INS_fnc_createIntel", false, false] spawn BIS_fnc_MP;
						deleteVehicle _intel;
						_listen = false;
					}; 
				} forEach _nearUnits;	
			};
		};	
	};
};

INS_fnc_initAIUnit = {
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

	if (side _unit == east) then { _unit addEventHandler ["Killed", INS_fnc_onDeathListener]; };
};