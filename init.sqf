if (!isServer && isNull player) then { isJIP = true; } else { isJIP = false; };
if (!isDedicated) then { waitUntil {!isNull player && isPlayer player}; };

#include "insurgency\core\functions.sqf"
#include "insurgency\core\ai_functions.sqf"
#include "insurgency\core\cas_functions.sqf"
#include "insurgency\core\cache_functions.sqf"

playerConnected ={
	diag_log format ["player connected: %1", _this];
	sleep 20;
	diag_log "Syncing markers...";

	{
		_x setMarkerColor   markerColor _x; 
		_x setMarkerAlpha   markerAlpha _x;
		_x setMarkerBrush   markerBrush _x;
		_x setMarkerDir     markerDir _x;
		_x setMarkerPos     markerPos _x;
		_x setMarkerShape   markerShape _x;
		_x setMarkerSize    markerSize _x;
		_x setMarkerText    markerText _x;
		_x setMarkerType    markerType _x;
	} forEach allMapMarkers;
};

if (isServer) then {
	//[] execVM "INS_revive\revive_init.sqf";
	//waitUntil {!isNil "INS_REV_FNCT_init_completed"};
	
	//[] execVM "insurgency\init_insurgency.sqf";
	[] execVM "insurgency\modules\vehicles\INS_veh_repair.sqf";
	[] execVM "insurgency\modules\vehicles\INS_veh_respawn.sqf"; // respawn loop
	//[] execVM "LV\ambientCombat.sqf";

	[] spawn { onPlayerConnected "[_id, _uid, _name] spawn { call playerConnected; };"; };
	
};

if (!isDedicated) then { // JIP player
	for [{_i = 0}, {_i < count(paramsArray)}, {_i = _i + 1}] do {
		_param = (configName ((missionConfigFile >> "Params") select _i));
		_value = (paramsArray select _i);
		diag_log format["%1 = %2", _param, _value];
		call compile format ["%1 = %2;", (configName ((missionConfigFile >> "Params") select _i)), (paramsArray select _i)];
	};

	[player] execVM "insurgency\modules\players\groups\INS_groups.sqf";
	[player] execVM "insurgency\modules\cas\init_cas.sqf";
	[] execVM "insurgency\modules\vehicles\INS_heli_fastRope.sqf";
};