if (isServer) {
	for [{_i = 0}, {_i < count(paramsArray)}, {_i = _i + 1}] do {
		_param = (configName ((missionConfigFile >> "Params") select _i));
		_value = (paramsArray select _i);
		format["%1 = %2", _param, _value] call BIS_fnc_log;
		call compile format ["%1 = %2; publicVariable ""%1""", (configName ((missionConfigFile >> "Params") select _i)), (paramsArray select _i)];
	};

	[] spawn "insurgency\modules\vehicles\INS_veh_respawn.sqf";
} else {
	
};