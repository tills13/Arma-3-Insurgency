// unit pools

_InfantryPool= ["O_SoldierU_SL_F", "O_soldierU_repair_F", "O_soldierU_medic_F", "O_sniper_F", "O_Soldier_A_F", "O_Soldier_AA_F", "O_Soldier_AAA_F", "O_Soldier_AAR_F", "O_Soldier_AAT_F", "O_Soldier_AR_F", "O_Soldier_AT_F", "O_soldier_exp_F", "O_Soldier_F", "O_engineer_F", "O_engineer_U_F", "O_medic_F", "O_recon_exp_F", "O_recon_F", "O_recon_JTAC_F", "O_recon_LAT_F", "O_recon_M_F", "O_recon_medic_F", "O_recon_TL_F"];	
_ArmoredPool= ["O_APC_Tracked_02_AA_F", "O_APC_Tracked_02_cannon_F", "O_APC_Wheeled_02_rcws_F", "O_MBT_02_arty_F", "O_MBT_02_cannon_F"];
_MotorPool=	["O_Truck_02_covered_F", "O_Truck_02_transport_F", "O_MRAP_02_F", "O_MRAP_02_gmg_F", "O_MRAP_02_hmg_F", "O_Truck_02_medical_F"];
_AttackChopperPool=	["O_Heli_Attack_02_black_F", "O_Heli_Attack_02_F"];
_TransportChopperPool= ["O_Heli_Light_02_F", "O_Heli_Light_02_unarmed_F"];
_uUAVPool= ["O_UAV_01_F", "O_UAV_02_CAS_F", "O_UGV_01_rcws_F"];
_StaticPool= ["O_Mortar_01_F", "O_static_AT_F", "O_static_AA_F"];
_ShipPool= ["O_Boat_Armed_01_hmg_F", "O_Boat_Transport_01_F"];
_DiverPool=	["O_diver_exp_F", "O_diver_F", "O_diver_TL_F"];
_CrewPool= ["O_crew_F"];
_HeliCrewPool=	["O_helicrew_F", "O_helipilot_F"];

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
				_eCount = count nearestObjects[_pos, ["Man"], 15];
				if (_eCount < 10) then {
					_m = createMarker [format ["box%1", random 1000], getposATL _building];
					//_m setMarkerText str floor random 1;
		            _m setMarkerShape "ICON"; 
		            _m setMarkerType "mil_dot";
		            _m setMarkerColor "ColorRed";
		            "O_SoldierU_SL_F" createUnit [_pos, createGroup east];
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

	_enemies = nearestObjects[_cityPos, ["Man"], _cityRad];
	_cachedEnemies = [];

	{
		if (alive _x) then {
			_eInfo = [typeOf _x, getPos _x, damage _x, group _x];
			deleteVehicle _x;
			diag_log format ["caching %1 at %2", typeOf _x, getPos _x];
			_cachedEnemies = _cachedEnemies + [_eInfo];
		};
		
	} forEach _enemies;

	diag_log str _cachedEnemies;
	missionNamespace setVariable [_cityName, _cachedEnemies];
};