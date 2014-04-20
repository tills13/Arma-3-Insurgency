player removeAction GRPMNU_groupActions;

doSetLeaderMP = {
	_group = _this select 0;
	_player = _this select 1;

	_group selectLeader _player;
};

GRPMNU_title = player addAction["<t color='#6775cf'>Group Options:</t>", "", nil, 1.05, false, false];
GRPMNU_joinGroup = player addAction["  Join Group", "insurgency\modules\players\groups\joinGroup.sqf", nil, 1.05, false, false, "", "(cursorTarget distance _this) < 20 && side cursorTarget == side _this && !(group player == group cursorTarget)"];
GRPMNU_dismissAI = player addAction["  Dismiss AI", "insurgency\modules\players\groups\dismissAI.sqf", nil, 1.05, false, false, "", "count ((group _this) call INS_fn_getAIinGroup) != 0 && (leader group _this == _this)"];
GRPMNU_leaveGroup = player addAction["  Leave Group", "insurgency\modules\players\groups\leaveGroup.sqf", nil, 1.05, false, false, "", "(count units group _this) > 1"];
GRPMNU_makeLead = player addAction["  Become Group Lead", "insurgency\modules\players\groups\leadGroup.sqf", nil, 1.05, false, false, "", "(count units group _this) > 1 && leader group _this != _this && !(isPlayer leader group _this)"];
GRPMNU_requestLead = player addAction["  Request Group Lead", {
	call compile format ["INS_GROUP_REQUEST_%1 = [true, '%2']", name leader group player, name player];
	publicVariable format["INS_GROUP_REQUEST_%1", name leader group player];

	format["INS_GROUP_REQUEST_RESPONSE_%1", name leader group player] addPublicVariableEventHandler {
		_response = _this select 1;	
		hint str _response;
		if (_response) then { 
			[[group player, player], "doSetLeaderMP", group player] spawn BIS_fnc_MP;
			hint parseText format ["Leading group <t color='#6775cf'>%1</t>", group player];
		};
	};

	call GRPMNU_removeActions;
}, nil, 1.05, false, false, "", "(count units group _this) > 1 && leader group _this != _this && isPlayer leader group _this"];
GRPMNU_leadAccept = player addAction["  Accept Leadership Request", {
	call compile format ["INS_GROUP_REQUEST_%1 = [false, '%1']", name player];
	call compile format ["INS_GROUP_REQUEST_RESPONSE_%1 = true", name player];
	publicVariable format["INS_GROUP_REQUEST_%1", name player];
	publicVariable format["INS_GROUP_REQUEST_RESPONSE_%1", name player];
	call GRPMNU_removeActions;
}, nil, 1.05, false, false, "", format["if (isNil 'INS_GROUP_REQUEST_%1') then {false} else {(INS_GROUP_REQUEST_%1 select 0)};", name player]];
GRPMNU_leadDecline = player addAction["  Deny Leadership Request", {
	call compile format ["INS_GROUP_REQUEST_%1 = [false, '%1']", name player];
	call compile format ["INS_GROUP_REQUEST_RESPONSE_%1 = false", name player];
	publicVariable format["INS_GROUP_REQUEST_%1", name player];
	publicVariable format["INS_GROUP_REQUEST_RESPONSE_%1", name player];
	call GRPMNU_removeActions;
}, nil, 1.05, false, false, "", format["if (isNil 'INS_GROUP_REQUEST_%1') then {false} else {(INS_GROUP_REQUEST_%1 select 0)};", name player]];
GRPMNU_quitLead = player addAction["  Step Down as Group Lead", "insurgency\modules\players\groups\quitLead.sqf", nil, 1.05, false, false, "", "(count units group _this) > 1 && leader group _this == _this"];
GRPMNU_exitGroup = player addAction["  <t color='#ff6347'>Exit Groups Menu</t>", GRPMNU_removeActions, nil, -1.04, false, true];