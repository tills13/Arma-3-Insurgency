/* ----------------------------------------------------------------------------------------------------
File: setupRecruitAIMenu.sqf
Author: dolan
    
Description:
sets all the addAction items for the flagpole
---------------------------------------------------------------------------------------------------- */
_this addAction ["Teleport to AHQ", "scripts\teleport.sqf", [player, AHQ]];
_this addAction ["Teleport to MHQ", "scripts\teleport.sqf", [player, MHQ]];

_this addAction ["Recruit Sniper", "scripts\recruitai.sqf", [player, "B_sniper_F"]];
_this addAction ["Recruit Spotter", "scripts\recruitai.sqf", [player, "B_spotter_F"]];
_this addAction ["Recruit Medic", "scripts\recruitai.sqf", [player, "B_medic_F"]];
_this addAction ["Recruit Engineer", "scripts\recruitai.sqf", [player, "B_engineer_F"]];
_this addAction ["Recruit Rifleman", "scripts\recruitai.sqf", [player, "B_soldier_F"]];
_this addAction ["Recruit Autorifleman", "scripts\recruitai.sqf", [player, "B_soldier_AR_F"]];
_this addAction ["Recruit AT Soldier", "scripts\recruitai.sqf", [player, "B_soldier_AT_F"]];