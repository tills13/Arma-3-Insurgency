private ["_caller"];
_caller = _this select 1;

_caller removeAction GRPMNU_groupActions;

GRPMNU_title = _caller addAction["<t color='#6775cf'>Group Options:</t>", "", nil, 1.05, false, false];
GRPMNU_joinGroup = _caller addAction["  Join Group", "insurgency\modules\players\groups\joinGroup.sqf", nil, 1.05, false, false, "", "(cursorTarget distance _this) < 20 && side cursorTarget == side _this"];
GRPMNU_dismissAI = _caller addAction["  Dismiss AI", "insurgency\modules\players\groups\dismissAI.sqf", nil, 1.05, false, false, "", "count ((group _this) call INS_fn_getAIinGroup) != 0"];
GRPMNU_leaveGroup = _caller addAction["  Leave Group", "insurgency\modules\players\groups\leaveGroup.sqf", nil, 1.05, false, false, "", "(count units group _this) > 1"];
GRPMNU_makeLead = _caller addAction["  Become Group Lead", "insurgency\modules\players\groups\leadGroup.sqf", nil, 1.05, false, false, "", "(count units group _this) > 1 && leader group _this != _this && !isPlayer leader group _this"];
GRPMNU_makeLead = _caller addAction["  Request Group Lead", {
	call compile format ["INS_GROUP_REQUEST_%1 = true", name leader group _caller];
	publicVariable format["INS_GROUP_REQUEST_%1", name _caller];

	format["INS_GROUP_REQUEST_RESPONSE_%1", name leader group _caller] addPublicVariableEventHandler {
		_response = _this select 1;		

		if (_response) then { group _caller selectLeader _caller; };
	};
}, nil, 1.05, false, false, "", "(count units group _this) > 1 && leader group _this != _this && isPlayer leader group _this"];
GRPMNU_makeLead = _caller addAction["  Accept Leadership Request", {
	call compile format ["INS_GROUP_REQUEST_%1 = false", name _caller];
	call compile format ["INS_GROUP_REQUEST_RESPONSE_%1 = 1", name _caller];
	publicVariable format["INS_GROUP_REQUEST_%1", name _caller];
	publicVariable format["INS_GROUP_REQUEST_RESPONSE_%1", name _caller];
}, nil, 1.05, false, false, "", format["INS_GROUP_REQUEST_%1 == true", name _caller];
GRPMNU_makeLead = _caller addAction["  Deny Leadership Request", {
	call compile format ["INS_GROUP_REQUEST_%1 = false", name _caller];
	call compile format ["INS_GROUP_REQUEST_RESPONSE_%1 = 0", name _caller];
	publicVariable format["INS_GROUP_REQUEST_%1", name _caller];
	publicVariable format["INS_GROUP_REQUEST_RESPONSE_%1", name _caller];
}, nil, 1.05, false, false, "", format["INS_GROUP_REQUEST_%1 == true", name _caller];
GRPMNU_quitLead = _caller addAction["  Step Down as Group Lead", "insurgency\modules\players\groups\quitLead.sqf", nil, 1.05, false, false, "", "(count units group _this) > 1 && leader group _this == _this"];
GRPMNU_exitGroup = _caller addAction["  <t color='#ff6347'>Exit Groups Menu</t>", GRPMNU_removeActions, nil, -1.04, false, true];