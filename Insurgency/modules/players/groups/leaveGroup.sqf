private ["_caller","_curGroup"];
_caller = _this select 1;

_curGroup = group _caller;
[_caller] join grpNull;

hint parseText format ["Left group <t color='#6775cf'>%1</t>", _curGroup];
[nil, _caller] call GRPMNU_removeActions;