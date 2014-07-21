if (!isServer && isNull player) then { isJIP = true; } else { isJIP = false; };
if (!isDedicated) then { waitUntil {!isNull player && isPlayer player}; };
enableSaving [false, false]; 

#include "insurgency\core\ai_unitPools.sqf";
#include "insurgency\core\functions.sqf"
#include "insurgency\core\ai_functions.sqf"
#include "insurgency\core\cas_functions.sqf"
#include "insurgency\core\cache_functions.sqf"
#include "insurgency\core\task_functions.sqf";

loadParams = {
	diag_log "Params : ------------------";
	for [{_i = 0}, {_i < count(paramsArray)}, {_i = _i + 1}] do {
		_param = (configName ((missionConfigFile >> "Params") select _i));
		_value = (paramsArray select _i);
		call compile format ["%1 = %2;", (configName ((missionConfigFile >> "Params") select _i)), (paramsArray select _i)];
	};

	INS_params_doneInit = false;
};

// server and players
call loadParams;
//call compile preprocessFile "insurgency\modules\spawn\INS_fnc_spawn.sqf";
call compile preprocessFile "insurgency\modules\revive\init_revive.sqf";

//server only
if (isServer) then {
	[] execVM "insurgency\init_insurgency.sqf";
	[] execVM "insurgency\modules\vehicles\INS_veh_repair.sqf";
	[] execVM "insurgency\modules\vehicles\INS_veh_respawn.sqf";
};

// players only
if (!isDedicated) then 	{
	[] execVM "insurgency\modules\players\INS_groups.sqf";
	[] execVM "insurgency\modules\cas\init_cas.sqf";
	[] execVM "insurgency\modules\vehicles\INS_heli_fastRope.sqf";

	player addEventHandler ["Respawn", {
		_unit = _this select 0;
		_corpse = _this select 1;

		//Strip the unit down
		removeAllWeapons _unit;
		{ _unit removeMagazine _x; } forEach (magazines _unit);

		removeUniform _unit;
		removeVest _unit;
		removeBackpack _unit;
		removeGoggles _unit;
		removeHeadGear _unit;
		removeWeapon _unit;
		removeMagazines _unit;
		{ _unit unassignItem _x; _unit removeItem _x; } forEach (assignedItems _unit);

		// appearance + items
		_unit addHeadgear headgear _corpse;
		_unit addGoggles goggles _corpse;
		_unit addUniform uniform _corpse;
		_unit addVest vest _corpse;
		_unit addBackpack backpack _corpse;

		{ _unit LinkItem _x; } forEach (assignedItems _corpse);
		{ _unit addMagazine _x; } forEach (magazines _corpse);
		{ _unit addWeapon _x; } forEach (weapons _corpse);
	}];
};