if (!isServer && isNull player) then { isJIP = true; } else { isJIP = false; };
if (!isDedicated) then { waitUntil {!isNull player && isPlayer player}; };

victoryColor = "colorGreen";
hostileColor = "colorRed";

if (isServer) then {
	[] execVM "INS_revive\revive_init.sqf";
	waitUntil {!isNil "INS_REV_FNCT_init_completed"};
	
	[] execVM "insurgency\init_insurgency.sqf";
	[] execVM "CAS\init_cas.sqf";
	//[] execVM "vehicles\zlt_fieldrepair.sqf";
	
};

// AI scripts 
//nul = [450,900,30,300,6,[1,1,0],player,"default",1,2500,nil,["CARELESS","SAD"],true] execVM "LV\ambientCombat.sqf";