if (isServer || isDedicated) then {
	call compile preprocessFile "insurgency\modules\ai\INS_fnc_spawnEnemies.sqf";
	call compile preprocessFile "insurgency\modules\intel\INS_fnc_spawnIntel.sqf";
	call compile preprocessFile "insurgency\modules\cache\INS_fnc_initCache.sqf";
};