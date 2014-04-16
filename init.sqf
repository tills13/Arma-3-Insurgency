if (!isServer && isNull player) then { isJIP = true; } else { isJIP = false; };
if (!isDedicated) then { waitUntil {!isNull player && isPlayer player}; };

victoryColor = "colorGreen";
hostileColor = "colorRed";

if (isServer) then {
	for [{_i = 0}, {_i < count(paramsArray)}, {_i = _i + 1}] do {
		_param = (configName ((missionConfigFile >> "Params") select _i));
		_value = (paramsArray select _i);
		format["%1 = %2", _param, _value] call BIS_fnc_log;
		call compile format ["%1 = %2; publicVariable ""%1""", (configName ((missionConfigFile >> "Params") select _i)), (paramsArray select _i)];
	};
	
	[] execVM "INS_revive\revive_init.sqf";
	waitUntil {!isNil "INS_REV_FNCT_init_completed"};
	
	[] execVM "insurgency\init_insurgency.sqf";
	[] execVM "CAS\init_cas.sqf";
	[] execVM "vehicles\zlt_fieldrepair.sqf";
	[] execVM "LV\ambientCombat.sqf";
};