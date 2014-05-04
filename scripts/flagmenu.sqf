/* ----------------------------------------------------------------------------------------------------
File: flagMenu.sqf
Author: dolan
    
Description:
---------------------------------------------------------------------------------------------------- */
INS_fnc_recruitAI = {
	private ["_unit"];
	_caller = _this select 1;;
	_type = (_this select 3) select 1;

	if (leader group _caller != _caller) then {
	    hint "Only the group leader can acquire AI, you are not the group leader!";
	} else {
        diag_log format ["%1 recruiting %2", name _caller, _type];
        _unit = group _caller createUnit [_type, getPos _caller, [], 10, "FORM"];
        _unit call INS_fnc_initAIUnit;
	};

	call FLAG_collapse_menu;
};

INS_fnc_teleport = {
	_player = (_this select 3) select 0;
	_dest = missionNamespace getVariable ((_this select 3) select 1);

	if (alive _dest) then { 
		_player setPos (getPos _dest);
		if (count crew _dest == 0) then { _player moveInDriver _dest; } else { _player moveInCargo _dest; };

		{ _x moveInCargo _dest; } forEach units group _player; // move all in group with you
	} else {
		hintSilent format["%1 currently not available", vehicleVarName _dest];
	};
};

FLAG_expand_menu = {
	_object = _this select 0;

	_object removeAction REC_MENU_AID;
	TITLE_ACTION_ID = _object addAction ["<t color='#6775cf'>Recruit: </t>", "", nil, 1.5, false, false];
	REC_sniper_AID = _object addAction ["  Sniper", INS_fnc_recruitAI, [player, "B_sniper_F"]];
	REC_spotter_AID = _object addAction ["  Spotter", INS_fnc_recruitAI, [player, "B_spotter_F"]];
	REC_medic_AID = _object addAction ["  Medic", INS_fnc_recruitAI, [player, "B_medic_F"]];
	REC_eng_AID = _object addAction ["  Engineer", INS_fnc_recruitAI, [player, "B_engineer_F"]];
	REC_soldier_AID = _object addAction ["  Rifleman", INS_fnc_recruitAI, [player, "B_soldier_F"]];
	REC_ar_AID = _object addAction ["  Autorifleman", INS_fnc_recruitAI, [player, "B_soldier_AR_F"]];
	REC_at_AID = _object addAction ["  AT Soldier", INS_fnc_recruitAI, [player, "B_soldier_AT_F"]];
	REC_cancel_AID = _object addAction ["  <t color='#ff6347'>Exit Recruit Menu</t>", FLAG_collapse_menu, nil, 1.5, false, false];
};

FLAG_collapse_menu = {
	_object = _this select 0;

	_object removeAction TITLE_ACTION_ID;
	_object removeAction REC_sniper_AID;
	_object removeAction REC_spotter_AID;
	_object removeAction REC_medic_AID;
	_object removeAction REC_eng_AID;
	_object removeAction REC_soldier_AID;
	_object removeAction REC_ar_AID;
	_object removeAction REC_at_AID;
	_object removeAction REC_cancel_AID;

	REC_MENU_AID = _object addAction ["<t color='#6775cf'>Recruit AI</t>", FLAG_expand_menu, nil, 1.5, false, false];
};

_object = _this;

TELAHQ_MENU_AID = _object addAction ["Teleport to AHQ", INS_fnc_teleport, [player, "AHQ"], 1.00, false, false, "", "alive AHQ"];
TELMHQ_MENU_AID = _object addAction ["Teleport to MHQ", INS_fnc_teleport, [player, "MHQ"], 1.00, false, false, "", "alive MHQ"];
REC_MENU_AID = _object addAction ["<t color='#6775cf'>Recruit AI</t>", FLAG_expand_menu, nil, 1.5, false, false];