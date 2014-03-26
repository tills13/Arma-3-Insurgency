waitUntil { isServer || !isNull player };

cacheLimit = paramsarray select 0;
intelItems = paramsarray select 1;
dropProb = paramsarray select 2;
destroyedRespawnDelay = paramsarray select 3;
abandonedRespawnDelay = paramsarray select 4;
intelTimeout = paramsarray select 5;
casPlayerTimeout = paramsarray select 6;
casAITimeout = paramsarray select 7;

victoryColor = "colorGreen";
hostileColor = "colorRed";
bastionColor = "colorOrange";
EOS_DAMAGE_MULTIPLIER = 1;
EOS_KILLCOUNTER = true;

#include "scripts\insurgency\core\functions.sqf"
#include "scripts\insurgency\core\cacheFunctions.sqf"
#include "scripts\insurgency\core\cacheGetPositions.sqf"

call compile preprocessfilelinenumbers "scripts\insurgency\init.sqf";
execVM "scripts\cas\initCAS.sqf";

// AI scripts 
//nul = [450,900,30,300,6,[1,1,0],player,"default",1,2500,nil,["CARELESS","SAD"],true] execVM "LV\ambientCombat.sqf";