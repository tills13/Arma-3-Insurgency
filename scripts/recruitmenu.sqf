/* ----------------------------------------------------------------------------------------------------
File: setupRecruitAIMenu.sqf
Author: dolan
    
Description:
sets all the addAction items for the flagpole
---------------------------------------------------------------------------------------------------- */
[[_this, "Teleport to AHQ", "scripts\teleport.sqf", [player, AHQ]], "actionMP", true, true] spawn BIS_fnc_MP;
[[_this, "Teleport to MHQ", "scripts\teleport.sqf", [player, MHQ]], "actionMP", true, true] spawn BIS_fnc_MP;

[[_this, "Recruit Sniper", "scripts\recruitai.sqf", [player, "B_sniper_F"]], "actionMP", true, true] spawn BIS_fnc_MP;
[[_this, "Recruit Spotter", "scripts\recruitai.sqf", [player, "B_spotter_F"]], "actionMP", true, true] spawn BIS_fnc_MP;
[[_this, "Recruit Medic", "scripts\recruitai.sqf", [player, "B_medic_F"]], "actionMP", true, true] spawn BIS_fnc_MP;
[[_this, "Recruit Engineer", "scripts\recruitai.sqf", [player, "B_engineer_F"]], "actionMP", true, true] spawn BIS_fnc_MP;
[[_this, "Recruit Rifleman", "scripts\recruitai.sqf", [player, "B_soldier_F"]], "actionMP", true, true] spawn BIS_fnc_MP;
[[_this, "Recruit Autorifleman", "scripts\recruitai.sqf", [player, "B_soldier_AR_F"]], "actionMP", true, true] spawn BIS_fnc_MP;
[[_this, "Recruit AT Soldier", "scripts\recruitai.sqf", [player, "B_soldier_AT_F"]], "actionMP", true, true] spawn BIS_fnc_MP;

actionMP = {
	private["_object", "_msg"];

	_object = _this select 0;
	_msg = _this select 1;
	_script = _this select 2;
	_args = _this select 3;

	if (isNull _object) exitWith {};

	_object addaction [_msg, _script, _args];
};