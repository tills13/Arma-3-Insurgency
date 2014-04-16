#include "core\functions.sqf"

if (isServer || isDedicated) then {
	[] execVM "insurgency\modules\ai\spawnEnemies.sqf";
	
	//[] execVM "insurgency\modules\markers\createMarkers.sqf";
	//waitUntil {!isNil "INS_CORE_doneCreate"};

	//[] execVM "insurgency\modules\intel\spawnIntel.sqf";
	//waitUntil {!isNil "INS_CORE_doneSpawnEnemies"};

	//[] execVM "insurgency\modules\cache\cache.sqf";
	//waitUntil {!isNil "INS_CORE_doneSpawnEnemies"};

	//call compile preprocessfilelinenumbers "insurgency\modules\cache\cache.sqf";
};