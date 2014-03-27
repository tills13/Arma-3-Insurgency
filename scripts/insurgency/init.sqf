if (isServer || isDedicated) then {
	proceed = false;
	publicVariable "proceed";

	null = ["null"] execVM "Scripts\insurgency\modules\ai\spawnEnemies.sqf";
	waitUntil { proceed };
	null = ["null"] execVM "Scripts\insurgency\modules\markersScript\createMarkers.sqf";
	[] execVM "Scripts\insurgency\modules\intel\spawnIntel.sqf";
};

call compile preprocessfilelinenumbers "Scripts\insurgency\modules\cache\cache.sqf";