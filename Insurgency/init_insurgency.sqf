#include "insurgency\core\functions.sqf"

if (isServer || isDedicated) then {
	proceed = false;
	publicVariable "proceed";

	[] execVM "insurgency\modules\ai\spawnEnemies.sqf";
	waitUntil { proceed };

	[] execVM "insurgency\modules\markersScript\createMarkers.sqf";
	[] execVM "insurgency\modules\intel\spawnIntel.sqf";
	call compile preprocessfilelinenumbers "insurgency\modules\cache\cache.sqf";
};