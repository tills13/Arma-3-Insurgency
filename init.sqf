if (!isServer && isNull player) then { isJIP = true; } else { isJIP = false; };
if (!isDedicated) then { waitUntil {!isNull player && isPlayer player}; };
enableSaving [false, false]; 

#include "insurgency\core\functions.sqf"
#include "insurgency\core\ai_functions.sqf"
#include "insurgency\core\cas_functions.sqf"
#include "insurgency\core\cache_functions.sqf"

loadParams = {
	if (isServer) then { diag_log "Server : ------------------"};
	if (!isDedicated) then { diag_log "Player : ------------------" };
	for [{_i = 0}, {_i < count(paramsArray)}, {_i = _i + 1}] do {
		_param = (configName ((missionConfigFile >> "Params") select _i));
		_value = (paramsArray select _i);
		//diag_log format["%1 = %2", _param, _value];
		call compile format ["%1 = %2;", (configName ((missionConfigFile >> "Params") select _i)), (paramsArray select _i)];
	};

	INS_params_doneInit = false;
};

// server and players
call loadParams;
//call compile preprocessFile "insurgency\modules\spawn\INS_fnc_spawn.sqf";
//call compile preprocessFile "insurgency\modules\revive\init_revive.sqf";

//server only
if (isServer) then {
	[] execVM "insurgency\init_insurgency.sqf";
	//[] execVM "insurgency\modules\vehicles\INS_veh_repair.sqf";
	//[] execVM "insurgency\modules\vehicles\INS_veh_respawn.sqf"; // respawn loop
	//[] execVM "LV\ambientCombat.sqf";

	/*[] spawn { 
		onPlayerConnected {
			diag_log format ["player connected: %1 (%2)", _name, _id];
			sleep 20;
			diag_log "Syncing markers...";

			{
				_x setMarkerColor markerColor _x; 
				_x setMarkerAlpha markerAlpha _x;
				_x setMarkerBrush markerBrush _x;
				_x setMarkerDir markerDir _x;
				_x setMarkerPos markerPos _x;
				_x setMarkerShape markerShape _x;
				_x setMarkerSize markerSize _x;
				_x setMarkerText markerText _x;
				_x setMarkerType markerType _x;
			} forEach allMapMarkers;
		};
	};*/
};

// players only
if (!isDedicated) then {
	//[] execVM "insurgency\modules\players\groups\INS_groups.sqf";
	//[] execVM "insurgency\modules\cas\init_cas.sqf";
	//[] execVM "insurgency\modules\vehicles\INS_heli_fastRope.sqf";
};