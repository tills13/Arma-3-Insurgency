private ["_caller"];
_caller = _this select 1;

_caller removeAction GRPMNU_groupActions;

GRPMNU_title = _caller addAction["<t color='#6775cf'>Group Options:</t>", "", nil, 1.05, false, false];
GRPMNU_joinGroup = _caller addAction["  Join Group", "insurgency\modules\players\groups\joinGroup.sqf", nil, 1.05, false, false, "", "(cursorTarget distance _this) < 20 && side cursorTarget == side _this"];
GRPMNU_dismissAI = _caller addAction["  Dismiss AI", "insurgency\modules\players\groups\dismissAI.sqf", nil, 1.05, false, false, "", "count ((group _this) call INS_fn_getAIinGroup) != 0"];
GRPMNU_leaveGroup = _caller addAction["  Leave Group", "insurgency\modules\players\groups\leaveGroup.sqf", nil, 1.05, false, false, "", "(count units group _this) > 1"];
GRPMNU_makeLead = _caller addAction["  Become Group Lead", "insurgency\modules\players\groups\leadGroup.sqf", nil, 1.05, false, false, "", "(count units group _this) > 1 && leader group _this != _this"];
GRPMNU_quitLead = _caller addAction["  Step Down as Group Lead", "insurgency\modules\players\groups\quitLead.sqf", nil, 1.05, false, false, "", "(count units group _this) > 1 && leader group _this == _this"];
GRPMNU_exitGroup = _caller addAction["  <t color='#ff6347'>Exit Groups Menu</t>", GRPMNU_removeActions, nil, -1.04, false, true];