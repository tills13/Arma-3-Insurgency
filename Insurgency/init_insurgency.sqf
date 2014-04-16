#include "core\functions.sqf"
#include "core\ai_functions.sqf"

if (isServer || isDedicated) then {
	call preprocessFile "insurgency\modules\ai\INS_fnc_spawnEnemies.sqf";
	
	//[] execVM "insurgency\modules\markers\createMarkers.sqf";
	//waitUntil {!isNil "INS_CORE_doneCreate"};

	//[] execVM "insurgency\modules\intel\spawnIntel.sqf";
	//waitUntil {!isNil "INS_CORE_doneSpawnEnemies"};

	//[] execVM "insurgency\modules\cache\cache.sqf";
	//waitUntil {!isNil "INS_CORE_doneSpawnEnemies"};

	//call compile preprocessfilelinenumbers "insurgency\modules\cache\cache.sqf";
};