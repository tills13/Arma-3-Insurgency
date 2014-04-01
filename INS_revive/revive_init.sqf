#include "config.sqf"

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

GVAR_is_arma3 = true;
Call Compile preprocessFileLineNumbers "INS_revive\revive\init_vanilla.sqf";
