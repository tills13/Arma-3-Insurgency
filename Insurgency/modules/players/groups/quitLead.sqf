private ["_newLead","_caller","_curGroup"];
_caller = _this select 1;

_curGroup = [];
_curGroup = units group _caller;
_newLead = _caller;

while {_newLead == _caller} do { _newLead = _curGroup select (floor(random(count _curGroup))); sleep 1.0; };

(group _caller) selectLeader _newLead;
hint parseText format ["No longer leading <t color='#6775cf'>%1</t>", group _caller];
[nil, _caller] call GRPMNU_removeActions;