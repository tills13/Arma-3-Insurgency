waitUntil { isServer || !isNull player };

cacheLimit = paramsarray select 1;
intelItems = paramsarray select 2;
dropProb = paramsarray select 3;
destroyedRespawnDelay = 0;//paramsarray select 4;
abandonedRespawnDelay = 0;//paramsarray select 5;
casPlayerTimeout = paramsarray select 6;
casAITimeout = paramsarray select 7;

#include "scripts\insurgency\core\functions.sqf"
#include "scripts\insurgency\core\cacheFunctions.sqf"
#include "scripts\insurgency\core\cacheGetPositions.sqf"

call compile preprocessfilelinenumbers "scripts\insurgency\init.sqf";
execVM "scripts\cas\initCAS.sqf";