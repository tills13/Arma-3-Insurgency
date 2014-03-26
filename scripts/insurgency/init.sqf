//if (isServer || isDedicated) then { null = ["null"] execVM "Scripts\insurgency\modules\markersScript\createMarkers.sqf"; };
if (isServer || isDedicated) then { null = ["null"] execVM "Scripts\insurgency\modules\ai\spawnEnemies.sqf"; };
call compile preprocessfilelinenumbers "Scripts\insurgency\modules\cache\cache.sqf";
if (isServer || isDedicated) then { [] execVM "Scripts\insurgency\modules\intel\spawnIntel.sqf"; };