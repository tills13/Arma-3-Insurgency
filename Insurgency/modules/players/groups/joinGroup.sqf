private ["_caller"];
_caller = _this select 1;

[_caller] join cursorTarget;
hint parseText format ["Joined group <t color='#6775cf'>%1</t>", group _caller];
[nil, _caller] call GRPMNU_removeActions;