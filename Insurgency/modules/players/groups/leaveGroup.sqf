private ["_caller","_curGroup"];
_caller = _this select 1;

_cGroup = group _caller;
if (leader group _caller == _caller) then {
	_curGroup = [];
	_curGroup = units group _caller;
	_newLead = _caller;

	while {_newLead == _caller} do { _newLead = _curGroup select (floor(random(count _curGroup))); sleep 1.0; };
	(group _caller) selectLeader _newLead;
};

[_caller] join grpNull;

hint parseText format ["Left group <t color='#6775cf'>%1</t>", _cGroup];
[nil, _caller] call GRPMNU_removeActions;