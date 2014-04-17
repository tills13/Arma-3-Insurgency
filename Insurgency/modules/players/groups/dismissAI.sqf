_caller = _this select 1;

(group _caller) call INS_fn_dismissAIFromGroup;
hint parseText format ["Dismissed AI in group <t color='#6775cf'>%1</t>", group _caller];
[nil, _caller] call GRPMNU_removeActions;