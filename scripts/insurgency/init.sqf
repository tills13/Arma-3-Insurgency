//if (isServer || isDedicated) then { null = ["null"] execVM "Scripts\insurgency\modules\markersScript\createMarkers.sqf"; };
//if (isServer || isDedicated) then { null = ["null"] execVM "Scripts\insurgency\modules\enemyScript\spawnEnemies.sqf"; };
call compile preprocessfilelinenumbers "Scripts\insurgency\modules\cacheScript\cache.sqf";
//if (isServer || isDedicated) then { [] execVM "Scripts\insurgency\modules\intelScript\spawnIntel.sqf"; };