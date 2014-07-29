if (isServer || isDedicated) then {
	//call dl_fnc_createMarkers;

	//call compile preprocessFile "insurgency\modules\intel\INS_fnc_spawnIntel.sqf";
	call compile preprocessFile "insurgency\modules\cache\INS_fnc_initCache.sqf";

	//[] execVM "insurgency\modules\ai\INS_ai_ambientCombat.sqf";

	INS_DONE_LOADING = true; publicVariable "INS_DONE_LOADING";
};