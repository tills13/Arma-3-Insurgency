// Prevent drown
// Usage : '[unit] call INS_rev_fnct_prevent_drown;'
INS_rev_fnct_prevent_drown = {
	private "_unit";
	_unit = _this select 0;
	_unit setOxygenRemaining 1;
};

// Check unit is underwater
// Usage(thread) : '[unit] call INS_rev_fnct_is_underwater;'
// Return : boot
INS_rev_fnct_is_underwater = {
	private ["_unit","_result"];
	_unit = _this select 0;
	_result = underwater _unit;
	_result
};

// Disable thermal cam
// Usage : 'call INS_rev_fnct_disalble_thermal_cam;'
INS_rev_fnct_disalble_thermal_cam = {
	false setCamUseTi 0;
};

INS_rev_fnct_a3_init_completed = true;