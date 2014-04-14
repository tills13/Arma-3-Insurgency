#include "config.sqf" // Load Config File

// Set JIP variable
if (isNil "isJIP") then {
	isJIP = false;
	player setVariable ["isJIP", false, true];
} else {
	if (isJIP) then {
		player setVariable ["isJIP", true, true];
	} else {
		player setVariable ["isJIP", false, true];
	};
};

// INS_revive Initializing
call compile preprocessFileLineNumbers "INS_revive\revive\init_vanilla.sqf";
