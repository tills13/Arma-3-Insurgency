private ["_injured", "_player", "_i","_playerMove","_startTime","_cancel_revive_action"];

scopeName "main";

// Set variable
_injured = _this select 0;
_player = player;
_startTime = time;
_reviveTakeTime = INS_rev_revive_take_time + (random 5);
INS_rev_GVAR_cancel_revive = false;

// Check medkit
if (INS_rev_require_medkit == 1) then {
	private ["_uniformItems","_vestItems","_backpackItems","_itemList"];
	_uniformItems = uniformItems _player;
	_vestItems = vestItems _player;
	_backpackItems = backpackItems _player;
	
	_itemList = _uniformItems + _vestItems + _backpackItems;
	
	if !("FirstAidKit" in _itemList) then {
		_player sidechat "You don't have a First Aid Kit."; 
		breakOut "main";
	};
};

// Protect player
[_player, false] call INS_rev_fnct_allowDamage;

// Infrom player is taking care of injured
_injured setVariable ["INS_rev_PVAR_who_taking_care_of_injured", _player, true];

// Attach to injured
_player attachTo [_injured, [-0.888, 0.222, 0]];
_player setDir 90;
_player playMoveNow "AinvPknlMstpSnonWrflDnon_medic";

// Set injured move
[_injured, "AinjPpneMstpSnonWrflDnon_rolltoback"] call INS_rev_fnct_playMoveNow;

// Detach player
if ([_player] call INS_rev_fnct_is_underwater) then {
	waitUntil {animationState _player == "AinvPknlMstpSnonWrflDnon_medic" || _startTime + _reviveTakeTime < time};
} else {
	sleep 0.5;
};

detach _player;

_cancel_revive_action = player addAction [STR_INS_rev_action_cancel_revive,	"insurgency\modules\revive\act_cancel_revive.sqf", [], 10, false, true,	"",	""]; // Add cancel revive action

// Wait _reviveTakeTime until player is alive and injured is not disconnected
while {!isNull _player && alive _player && !isNull _injured && alive _injured && _startTime + _reviveTakeTime > time && !INS_rev_GVAR_cancel_revive} do {
	_playerMove = format ["AinvPknlMstpSnonWrflDnon_medic0", floor random 6];
	_player playMove _playerMove;
	waitUntil {animationState _player == _playerMove || INS_rev_GVAR_cancel_revive || _startTime + _reviveTakeTime < time};
	waitUntil {animationState _player != _playerMove || INS_rev_GVAR_cancel_revive || _startTime + _reviveTakeTime < time};
	_player playMoveNow "AinvPknlMstpSnonWrflDnon_medic";
};


// Check medkit
if (INS_rev_require_medkit == 1) then {
	private ["_uniformItems","_vestItems","_backpackItems","_itemList"];
	_uniformItems = uniformItems _player;
	_vestItems = vestItems _player;
	_backpackItems = backpackItems _player;
	
	_itemList = _uniformItems + _vestItems + _backpackItems;
	
	if !("FirstAidKit" in _itemList) then {
		// Reset variable
		_injured setVariable ["INS_rev_PVAR_who_taking_care_of_injured", nil, true];

		// Finish player revive action
		if !(isNull _player) then {
			if (alive _player && !INS_rev_GVAR_cancel_revive) then {
				_player playMoveNow "AinvPknlMstpSnonWrflDnon_medicEnd";
				sleep 1;
			} else {
				_player playMoveNow "amovpknlmstpsraswrfldnon";
			};
			_player removeAction _cancel_revive_action;
		};

		// Clear variable
		INS_rev_GVAR_cancel_revive = nil;
		_player sidechat "You don't have a FirstAid kit."; 
		breakOut "main";
	} else {
		_player removeItem "FirstAidKit";
	};
};

// If injured is not disconnected
if !(isNull _injured) then {
	// If player and injured is alive
	if (!isNull _player && alive _player && alive _injured && !INS_rev_GVAR_cancel_revive) then {
		INS_rev_GVAR_end_unconscious = _injured;
		publicVariable "INS_rev_GVAR_end_unconscious";
		["INS_rev_GVAR_end_unconscious", INS_rev_GVAR_end_unconscious] spawn INS_rev_fnct_remove_actions;
		
		// Set variable
		_injured setVariable ["INS_rev_PVAR_is_unconscious", false, true];
		
		// Set injured move
		[_injured, "AmovPpneMstpSrasWrflDnon"] call INS_rev_fnct_playMoveNow;
		//[_injured, "AmovPpneMstpSnonWnonDnon_healed"] call INS_rev_fnct_playMoveNow;
	};
	
	// Reset variable
	_injured setVariable ["INS_rev_PVAR_who_taking_care_of_injured", nil, true];
};

// Finish player revive action
if !(isNull _player) then {
	if (alive _player && !INS_rev_GVAR_cancel_revive) then {
		_player playMoveNow "AinvPknlMstpSnonWrflDnon_medicEnd";
		sleep 1;
	} else {
		_player playMoveNow "amovpknlmstpsraswrfldnon";
	};
	
	_player removeAction _cancel_revive_action;
};

[_player, true] call INS_rev_fnct_allowDamage; // Unprotect player
INS_rev_GVAR_cancel_revive = nil; // Clear variable