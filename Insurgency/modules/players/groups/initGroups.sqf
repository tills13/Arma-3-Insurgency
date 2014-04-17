GRPMNU_removeActions = {
	_caller = _this select 1;

	_caller removeAction GRPMNU_title;
	_caller removeAction GRPMNU_exitGroup;
	_caller removeAction GRPMNU_dismissAI;
	_caller removeAction GRPMNU_joinGroup;
	_caller removeAction GRPMNU_leaveGroup;
	_caller removeAction GRPMNU_makeLead;
	_caller removeAction GRPMNU_quitLead;

	GRPMNU_groupActions = _caller addAction["<t color='#6775cf'>Groups Menu</t>", "insurgency\modules\players\groups\groupActions.sqf", nil, 1.05, false, false, "", "_target == vehicle _this || _target == _this"];
};


if (!isNull player) then {
    GRPMNU_groupActions = player addAction["<t color='#6775cf'>Groups Menu</t>", "insurgency\modules\players\groups\groupActions.sqf", nil, 1.05, false, false, "", "_target == vehicle _this || _target == _this"];
    
    player addEventHandler ["Respawn", {
        GRPMNU_groupActions = player addAction["<t color='#6775cf'>Groups Menu</t>", "insurgency\modules\players\groups\groupActions.sqf", nil, 1.05, false, false, "", "_target == vehicle _this || _target == _this"];
    }];
};