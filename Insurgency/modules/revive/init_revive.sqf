INS_rev_list_of_respawn_locations_blufor = ["AHQ", "MHQ", "FLAG"];
INS_rev_list_of_respawn_locations_opfor = [];
INS_rev_list_of_respawn_locations_civ = [];
INS_rev_list_of_respawn_locations_guer = [];
INS_rev_language = "en";
INS_rev_list_of_classnames_who_can_revive = [];
INS_rev_list_of_slots_who_can_revive = [];

if (INS_rev_respawn_type != 0) then { INS_rev_player_marker_serverSide = false; } else { INS_rev_player_marker_serverSide = true; };

if (isNil "isJIP") then {
	isJIP = false;
	player setVariable ["isJIP", false, true];
} else {
	if (isJIP) then { player setVariable ["isJIP", true, true]; } 
	else { player setVariable ["isJIP", false, true]; };
};

// Load language string
call compile preprocessFile format ["insurgency\modules\revive\%1_strings_lang.sqf", INS_rev_language];

// Call functions
call compile preprocessFile "insurgency\modules\revive\functions.sqf";
waitUntil {!isNil "INS_rev_fnct_init_completed"};

call compile preprocessFile "insurgency\modules\revive\functions_a3.sqf";
waitUntil {!isNil "INS_rev_fnct_a3_init_completed"};

// If not player then exit
if (!isDedicated) then {
	[] spawn {
		private ["_loadout", "_playableUnits"];

		INS_rev_thread_exec_wait_revive = [] spawn {};	// On killed waiting revive thread
		INS_rev_thread_dead_camera = [] spawn {};		// On killed dead camera thread
		
		waitUntil {!(isNull player)}; // Wait until player initialized
		
		// Display Respawn Locations Marker
		if (INS_rev_displayRespawnLocationMarker == 1) then {
			[] spawn INS_rev_fnct_displayRespawnLocationMarker;
		};
		
		// Memorize player's body before dead
		INS_rev_GVAR_body_before_dead = player;
		
		// Add event handler
		player addEventHandler ["killed", INS_rev_fnct_onKilled];
		"INS_rev_GVAR_start_unconscious" addPublicVariableEventHandler INS_rev_fnct_add_actions;
		"INS_rev_GVAR_end_unconscious" addPublicVariableEventHandler INS_rev_fnct_remove_actions;
		"INS_rev_GVAR_add_unload" addPublicVariableEventHandler INS_rev_fnct_add_unload_action;
		"INS_rev_GVAR_del_unload" addPublicVariableEventHandler INS_rev_fnct_remove_unload_action;
		
		sleep 0.5;
		
		// Initialize Variable
		player setVariable ["INS_rev_PVAR_is_unconscious", false, true];
		player setVariable ["INS_rev_PVAR_isTeleport", false, true];
		player setVariable ["INS_rev_PVAR_playerSide", side player, true];
		player setVariable ["INS_rev_PVAR_playerGroup", group player, true];
		player setVariable ["INS_rev_PVAR_playerGroupColor", [player] call INS_rev_fnct_get_group_color, true];
		player setVariable ["INS_rev_PVAR_who_taking_care_of_injured", nil, true];
		player setVariable ["INS_rev_PVAR_is_dead", false, true];
		
		// Initialize other players state (JIP, disabledAI, ...)
		_playableUnits = playableUnits;
		
		{
			["INS_rev_GVAR_end_unconscious", _x] call INS_rev_fnct_remove_actions;
			
			if (_x != player) then {
				if !(isNil {_x getVariable "INS_rev_PVAR_is_unconscious"}) then	{
					if (_x getVariable "INS_rev_PVAR_is_unconscious") then {
						["INS_rev_GVAR_start_unconscious", _x] call INS_rev_fnct_add_actions;
					};
				};
			};
		} forEach _playableUnits;
		
		if (isJIP) then { // JIP Process
			switch (INS_rev_jip_action) do {
				case 0: { }; // none
				case 1: { call INS_rev_fnct_init_teleport_to_teamate; };
				case 2: {
					player setVariable ["INS_rev_PVAR_isTeleport", true, true];
					[player, player] call INS_rev_fnct_onKilled;
				};
			};
		};
	};
};
