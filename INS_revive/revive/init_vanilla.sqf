/*
 * Initialize INS_revive system.
 * 
 * Copyleft 2013 naong
 * 
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 

// Load language string
call compile preprocessFile format ["INS_revive\revive\%1_strings_lang.sqf", INS_REV_CFG_language];

// Call functions
call compile preprocessFile "INS_revive\revive\functions.sqf";
waitUntil {!isNil "INS_REV_FNCT_init_completed"};

call compile preprocessFile "INS_revive\revive\functions_a3.sqf";
waitUntil {!isNil "INS_REV_FNCT_a3_init_completed"};


// Start serverside scripts
if (isServer) then {
	// Set makers when player dead
	if (INS_REV_CFG_player_marker_serverSide) then {
		INS_REV_thread_draw_dead_marker = [] spawn INS_REV_FNCT_draw_dead_marker;
	};
};

// If not player then exit
if (!isDedicated) then {
	diag_log "INS initialized and running for player";
	[] spawn {
		private ["_loadout", "_playableUnits"];

		INS_REV_thread_exec_wait_revive = [] spawn {};	// On killed waiting revive thread
		INS_REV_thread_dead_camera = [] spawn {};		// On killed dead camera thread
		
		waitUntil {!(isNull player)}; // Wait until player initialized
		
		// Display Respawn Locations Marker
		if (INS_REV_CFG_displayRespawnLocationMarker) then {
			[] spawn INS_REV_FNCT_displayRespawnLocationMarker;
		};
		
		// Initialize Player Loadout
		_loadout = [player] call INS_REV_FNCT_get_loadout;
		INS_REV_GVAR_player_loadout = _loadout;
		INS_REV_GVAR_player_loadout_time = time;

		if (!INS_REV_CFG_loadout_on_respawn) then {
			[] spawn INS_REV_FNCT_respawnBlock;
		};
		
		// Memorize player's body before dead
		INS_REV_GVAR_body_before_dead = player;
		
		// Add event handler
		player addEventHandler ["killed", INS_REV_FNCT_onKilled];
		"INS_REV_GVAR_start_unconscious" addPublicVariableEventHandler INS_REV_FNCT_add_actions;
		"INS_REV_GVAR_end_unconscious" addPublicVariableEventHandler INS_REV_FNCT_remove_actions;
		"INS_REV_GVAR_add_unload" addPublicVariableEventHandler INS_REV_FNCT_add_unload_action;
		"INS_REV_GVAR_del_unload" addPublicVariableEventHandler INS_REV_FNCT_remove_unload_action;
		if (!INS_REV_CFG_loadout_on_respawn) then {
			player addEventHandler ["HandleDamage", {_this call INS_REV_FNCT_clientHD}];
		};
		
		sleep 0.5;
		
		// Initialize Variable
		player setVariable ["INS_REV_PVAR_is_unconscious", false, true];
		player setVariable ["INS_REV_PVAR_isTeleport", false, true];
		player setVariable ["INS_REV_PVAR_playerSide", side player, true];
		player setVariable ["INS_REV_PVAR_playerGroup", group player, true];
		player setVariable ["INS_REV_PVAR_playerGroupColor", [player] call INS_REV_FNCT_get_group_color, true];
		player setVariable ["INS_REV_PVAR_who_taking_care_of_injured", nil, true];
		player setVariable ["INS_REV_PVAR_is_dead", false, true];
		
		// Initialize other players state (JIP, disabledAI, ...)
		_playableUnits = playableUnits;
		{
			["INS_REV_GVAR_end_unconscious", _x] call INS_REV_FNCT_remove_actions;
			
			if (_x != player) then {
				if !(isNil {_x getVariable "INS_REV_PVAR_is_unconscious"}) then	{
					if (_x getVariable "INS_REV_PVAR_is_unconscious") then {
						["INS_REV_GVAR_start_unconscious", _x] call INS_REV_FNCT_add_actions;
					};
				};
			};
		} forEach _playableUnits;
		
		// JIP Process
		if (isJIP) then {
			switch (INS_REV_CFG_JIP_Teleport_Action) do {
				case 0: {
					// none
				};
				case 1: {
					// add 'Teleport to teammate' action
					call INS_REV_FNCT_init_teleport_to_teamate;
				};
				case 2: {
					// dead camera
					player setVariable ["INS_REV_PVAR_isTeleport", true, true];
					[player, player] call INS_REV_FNCT_onKilled;
				};
			};
		};
	};
};
