private ["_caller"];
_caller = _this select 1;


group _caller selectLeader _caller;
hint parseText format ["Leading group <t color='#6775cf'>%1</t>", group _caller];
[nil, _caller] call GRPMNU_removeActions;