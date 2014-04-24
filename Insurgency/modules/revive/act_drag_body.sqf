private ["_injured", "_player", "_release_body_action","_carry_body_action","_playerMove","_wrong_moves","_trigger"];

// Set variable
_injured = _this select 0;
_player = player;
_wrong_moves = ["helper_switchtocarryrfl","acinpknlmstpsraswrfldnon_amovppnemstpsraswrfldnon","acinpknlmstpsraswrfldnon_acinpercmrunsraswrfldnon","acinpercmrunsraswrfldnon","acinpercmrunsraswrfldf"];
_prone_moves = ["amovppnemstpsraswrfldnon","amovppnemrunslowwrfldf","amovppnemsprslowwrfldfl","amovppnemsprslowwrfldfr","amovppnemrunslowwrfldb","amovppnemsprslowwrfldbl","amovppnemsprslowwrfldr","amovppnemstpsraswrfldnon_turnl","amovppnemstpsraswrfldnon_turnr","amovppnemrunslowwrfldl","amovppnemrunslowwrfldr","amovppnemsprslowwrfldb","amovppnemrunslowwrfldbl","amovppnemsprslowwrfldl","amovppnemsprslowwrfldbr"];
INS_rev_GVAR_do_release_body = false;
INS_rev_GVAR_is_carring = false;
INS_rev_GVAR_injured = _injured;

// If while prone
if (animationState player in _prone_moves) exitWith {
	_this execVM "insurgency\modules\revive\act_drag_body_prone.sqf";
};

// Infrom player is taking care of injured
_injured setVariable ["INS_rev_PVAR_who_taking_care_of_injured", _player, true];

// Add release body action
_release_body_action = _player addAction [STR_INS_rev_action_release_body, "insurgency\modules\revive\act_release_body.sqf", _injured, 10, false, true, "", ""];

// Add load body action
if (INS_rev_medevac == 1) then {
	if (isNil "FNC_check_load_vehicle") then {
		FNC_check_load_vehicle = {
			private ["_objs","_vcl","_result"];
			_result = false;
			_objs = nearestObjects [player, ["Car","Tank","Helicopter","Plane","Boat"], 5];
			INS_rev_GVAR_load_vehicle = nil;
			if (count _objs > 0) then {
				INS_rev_GVAR_load_vehicle = _objs select 0;
				if (alive INS_rev_GVAR_load_vehicle) then {
					_result = true;
				};
			};
			_result
		};
	};
	
	_trigger = createTrigger["EmptyDetector" ,getPos player];
	_trigger setTriggerArea [0, 0, 0, true];
	_trigger setTriggerActivation ["NONE", "PRESENT", true];
	_trigger setTriggerStatements[
		"call FNC_check_load_vehicle",
		"INS_rev_GVAR_loadActionID = player addAction [format[STR_INS_rev_action_load_body,name INS_rev_GVAR_injured,getText(configFile >> 'CfgVehicles' >> typeOf INS_rev_GVAR_load_vehicle >> 'displayname')], 'insurgency\modules\revive\act_load_body.sqf',[INS_rev_GVAR_injured,INS_rev_GVAR_load_vehicle],10,false];",
		"player removeAction INS_rev_GVAR_loadActionID; INS_rev_GVAR_loadActionID = nil;"
	];
};

// Attach player to injured
_injured attachTo [_player, [0, 1.1, 0.092]];
[_injured, 180] call INS_rev_fnct_setDir;

// Start dragging move
_playerMove = "AcinPknlMstpSrasWrflDnon";
_player playMoveNow _playerMove;
waitUntil {animationState player == _playerMove};
waitUntil {(animationState _player == "acinpknlmwlksraswrfldb" || animationState _player == "acinpknlmstpsraswrfldnon")};

// Set injured move
if !(call INS_rev_fnct_is_finished_dragging) then {
	[_injured, "AinjPpneMrunSnonWnonDb_grab"] call INS_rev_fnct_switchMove;
};

// Add carry body action
if ((INS_rev_medevac == 1) && (INS_rev_can_carry_body == 1)) then {
	_carry_body_action = _player addAction [STR_INS_rev_action_carry_body, "insurgency\modules\revive\act_carry_body.sqf", [_injured, _release_body_action, _trigger], 10, false, true, "", ""];
} else {
	_carry_body_action = _player addAction [STR_INS_rev_action_carry_body, "insurgency\modules\revive\act_carry_body.sqf", [_injured, _release_body_action, nil], 10, false, true, "", ""];
};


// Wait until dragging is finished
while {!(call INS_rev_fnct_is_finished_dragging) || INS_rev_GVAR_is_carring} do {
	sleep 0.5;
};

if (!isNil "INS_rev_GVAR_is_carring" && {INS_rev_GVAR_is_carring}) exitWith {};

// If injured is not disconnected, release body
if !(isNull _injured) then {
	detach _injured;
	
	if (_injured getVariable "INS_rev_PVAR_is_unconscious") then {
		[_injured, "AinjPpneMstpSnonWrflDnon"] call INS_rev_fnct_switchMove;
	};
	_injured setVariable ["INS_rev_PVAR_who_taking_care_of_injured", nil, true];
};

// Finish dragging
if !(isNull _player) then {
	// If player is dead, terminate move
	if (!alive _player) then {
		[_player, "AmovPknlMstpSrasWrflDnon"] call INS_rev_fnct_switchMove;
	} else {
		// If player stand up, terminate move
		if ((animationState _player) in _wrong_moves) then {
			while {(animationState _player) in _wrong_moves} do {
				[_player, "AmovPknlMstpSrasWrflDnon"] call INS_rev_fnct_switchMove;
				sleep 0.5;
			};
		} else {
			_player playMoveNow "AmovPknlMstpSrasWrflDnon";
		};
	};
};

// Remove  actions
_player removeAction _release_body_action;
_player removeAction _carry_body_action;
if (INS_rev_medevac == 1) then {
	if (!isNil "INS_rev_GVAR_loadActionID") then {
		_player removeAction INS_rev_GVAR_loadActionID;
		INS_rev_GVAR_loadActionID = nil;
	};
	
	// Remove trigger
	if (!isNull _trigger) then {
		deleteVehicle _trigger;
		_trigger = nil;
	};
};

// Clear variable
INS_rev_GVAR_do_release_body = nil;
INS_rev_GVAR_injured = nil;