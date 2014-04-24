/*
 * Load body action
 * 
 * Copyleft 2013 naong
 * 
 * This program is free software under the terms of the GNU General Public License version 3.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

private ["_player","_injured","_load_vehicle"];

_player = player;
_injured = (_this select 3) select 0;
_load_vehicle = (_this select 3) select 1;

if (!isNull _injured && alive _injured && _injured getVariable "INS_rev_PVAR_is_unconscious") then {
	if (_load_vehicle emptyPositions "Cargo" > 0) then {
		// Load injured to vehicle
		detach _injured;
		[_injured, _load_vehicle] call INS_rev_fnct_moveInCargo;
		//[_injured, "kia_hmmwv_driver"] call INS_rev_fnct_switchMove;
		[_injured, "AinjPpneMstpSnonWrflDnon"] call INS_rev_fnct_switchMove;
		//[_injured, "kia_passenger_mrap_01_front"] call INS_rev_fnct_switchMove;
		_player playMoveNow "AmovPknlMstpSrasWrflDnon";
		
		// Add unload action
		INS_rev_GVAR_add_unload = [_load_vehicle, _injured];
		publicVariable "INS_rev_GVAR_add_unload";
		["INS_rev_GVAR_add_unload", INS_rev_GVAR_add_unload] spawn INS_rev_fnct_add_unload_action;
		_injured setVariable ["INS_rev_PVAR_who_taking_care_of_injured", nil, true];
		
		sleep 0.5;
		
		// Check injured is loaded
		if (vehicle _injured != _injured) then {
			player sidechat format["'%1' loaded into '%2'", name _injured, getText(configFile >> 'CfgVehicles' >> typeOf _load_vehicle >> 'displayname')];
		} else {
			// Swtich move
			if (_injured getVariable "INS_rev_PVAR_is_unconscious") then {
				[_injured, "AinjPpneMstpSnonWrflDnon"] call INS_rev_fnct_switchMove;
				while {animationState _injured != "AinjPpneMstpSnonWrflDnon"} do {
					sleep 0.1;
					[_injured, "AinjPpneMstpSnonWrflDnon"] call INS_rev_fnct_switchMove;
				};
			};
			
			// Remove unload action
			INS_rev_GVAR_del_unload = [_load_vehicle, _injured];
			publicVariable "INS_rev_GVAR_del_unload";
			["INS_rev_GVAR_del_unload", INS_rev_GVAR_del_unload] spawn INS_rev_fnct_remove_unload_action;
			
			player sidechat format["Failed loading", name _injured, getText(configFile >> 'CfgVehicles' >> typeOf _load_vehicle >> 'displayname')];
		};
	} else {
		player sidechat format["There's no cargo space in '%1'", getText(configFile >> 'CfgVehicles' >> typeOf _load_vehicle >> 'displayname')];
	};
};