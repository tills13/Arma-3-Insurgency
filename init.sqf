if (!isServer && isNull player) then {isJIP=true;} else {isJIP=false;};
if (!isDedicated) then {waitUntil {!isNull player && isPlayer player};};

cacheLimit = paramsarray select 0;
intelItems = paramsarray select 1;
dropProb = paramsarray select 2;
destroyedRespawnDelay = paramsarray select 3;
abandonedRespawnDelay = paramsarray select 4;
intelTimeout = paramsarray select 5;
casPlayerTimeout = paramsarray select 6;
casPlayerTimeLimit = paramsarray select 7;
casAITimeout = 0;// = paramsarray select 8;
weatherChangeRate = paramsarray select 9;
debugMode = if ((paramsarray select 10) == 1) then {true} else {false};

onplayerConnected {
	publicVariable "cacheLimit";
	publicVariable "intelItems";
	publicVariable "dropProb";
	publicVariable "destroyedRespawnDelay";
	publicVariable "abandonedRespawnDelay";
	publicVariable "intelTimeout";
	publicVariable "casPlayerTimeout";
	publicVariable "casPlayerTimeLimit";
	publicVariable "casAITimeout";
	publicVariable "weatherChangeRate";
	publicVariable "debugMode";
};

victoryColor = "colorGreen";
hostileColor = "colorRed";
bastionColor = "colorOrange";

#include "scripts\insurgency\core\functions.sqf"
#include "scripts\insurgency\core\cacheFunctions.sqf"
#include "scripts\insurgency\core\cacheGetPositions.sqf"

call compile preprocessfilelinenumbers "scripts\insurgency\init.sqf";
execVM "scripts\cas\initCAS.sqf";
[] execVM "scripts\vehicles\zlt_fieldrepair.sqf";
[] execVM "INS_revive\revive_init.sqf";

//waitUntil {!isNil "INS_REV_FNCT_init_completed"};

// AI scripts 
//nul = [450,900,30,300,6,[1,1,0],player,"default",1,2500,nil,["CARELESS","SAD"],true] execVM "LV\ambientCombat.sqf";
