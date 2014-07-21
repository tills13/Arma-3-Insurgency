// Remote execution
INS_rev_fnct_remote_exec = {
	private ["_unit", "_command", "_parameter"];
	_unit = _this select 1 select 0;
	_command = _this select 1 select 1;
	_parameter = _this select 1 select 2;
	
	if (_command == "switchMove") exitWith {
		_unit switchMove _parameter;
	};
	
	if (_command == "allowDamage") exitWith {
		if (_parameter) then {
			_unit allowDamage true;
			_unit setCaptive false;
		} else {
			_unit allowDamage false;
			_unit setCaptive true;
		};
	};
	
	if (local _unit) then {
		switch (_command) do {
			case "setDir":		{_unit setDir _parameter;};
			case "playMove":	{_unit playMove _parameter;};
			case "playMoveNow":	{_unit playMoveNow _parameter;};
			case "moveInCargo":	{_unit moveInCargo _parameter;};
		};
	};
};

"INS_rev_GVAR_remote_exec" addPublicVariableEventHandler INS_rev_fnct_remote_exec;

// Switch move
// Usage : '[_unit, _move] call INS_rev_fnct_switchMove;'
INS_rev_fnct_switchMove = {
	private ["_unit", "_move"];
	
	_unit = _this select 0;
	_move = _this select 1;
	
	//_unit switchMove _move;
	//processInitCommands;
	INS_rev_GVAR_remote_exec = [_unit, "switchMove", _move];
	publicVariable "INS_rev_GVAR_remote_exec";
	["INS_rev_GVAR_remote_exec", INS_rev_GVAR_remote_exec] spawn INS_rev_fnct_remote_exec;
};

// Set allow damage
// Usage : '[_unit, _value] call INS_rev_fnct_allowDamage;'
INS_rev_fnct_allowDamage = {
	private ["_unit", "_value"];
	
	_unit = _this select 0;
	_value = _this select 1;
	
	INS_rev_GVAR_remote_exec = [_unit, "allowDamage", _value];
	publicVariable "INS_rev_GVAR_remote_exec";
	["INS_rev_GVAR_remote_exec", INS_rev_GVAR_remote_exec] spawn INS_rev_fnct_remote_exec;
};

// Set dir
// Usage : '[_unit, _value] call INS_rev_fnct_setDir;'
INS_rev_fnct_setDir = {
	private ["_unit", "_dir"];
	_unit = _this select 0;
	_dir = _this select 1;
	
	INS_rev_GVAR_remote_exec = [_unit, "setDir", _dir];
	publicVariable "INS_rev_GVAR_remote_exec";
	["INS_rev_GVAR_remote_exec", INS_rev_GVAR_remote_exec] spawn INS_rev_fnct_remote_exec;
};

// Play move
// Usage : '[_unit, _move] call INS_rev_fnct_playMoveNow;'
INS_rev_fnct_playMove = {
	private ["_unit", "_move"];
	_unit = _this select 0;
	_move = _this select 1;
	
	INS_rev_GVAR_remote_exec = [_unit, "playMove", _move];
	publicVariable "INS_rev_GVAR_remote_exec";
	["INS_rev_GVAR_remote_exec", INS_rev_GVAR_remote_exec] spawn INS_rev_fnct_remote_exec;
};

// Play move now
// Usage : '[_unit, _move] call INS_rev_fnct_playMoveNow;'
INS_rev_fnct_playMoveNow = {
	private ["_unit", "_move"];
	_unit = _this select 0;
	_move = _this select 1;
	
	INS_rev_GVAR_remote_exec = [_unit, "playMoveNow", _move];
	publicVariable "INS_rev_GVAR_remote_exec";
	["INS_rev_GVAR_remote_exec", INS_rev_GVAR_remote_exec] spawn INS_rev_fnct_remote_exec;
};

// Move in cargo
// Usage : '[_unit, _vehicle] call INS_rev_fnct_moveInCargo;'
INS_rev_fnct_moveInCargo = {
	private ["_unit", "_vehicle"];
	
	_unit = _this select 0;
	_vehicle = _this select 1;
	
	INS_rev_GVAR_remote_exec = [_unit, "moveInCargo", _vehicle];
	publicVariable "INS_rev_GVAR_remote_exec";
	["INS_rev_GVAR_remote_exec", INS_rev_GVAR_remote_exec] spawn INS_rev_fnct_remote_exec;
};

// Check vehicle is full
// Usage : 'call INS_rev_fnct_vclisFull;'
// Return : bool
INS_rev_fnct_vclisFull = { 
	private ["_result", "_turrets", "_sub_turrets"];
	
	scopeName "main";
	_result = true;
	
	if (_this isKindOf "man" || _this isKindOf "building") exitWith { false };
	if (_this emptyPositions "Driver" > 0) exitWith { false };
	if (_this emptyPositions "Gunner" > 0)exitWith  { false };
	if (_this emptyPositions "Commander" > 0) exitWith { false };
	if (_this emptyPositions "Cargo" > 0) exitWith { false };
	
	// Check turrets
	_turrets = configFile >> "CfgVehicles" >> typeof _this >> "turrets";
	if (count _turrets > 0) then {
		for "_i" from 0 to (count _turrets) - 1 do {
			if (isNull (_this turretUnit [_i])) then { _result = false; breakTo "main";};
			
			_sub_turrets = _x >> "turrets";
			if (count _sub_turrets > 0) then {
				for "_j" from 0 to (count _sub_turrets) - 1 do {
					if (isNull (_this turretUnit [_i, _j])) then { _result = false; breakTo "main";};
				};
			};
		};
	};
	
	_result
};

// Move in vehicle
// Usage : '[unit, vehicle] call INS_rev_fnct_moveInVehicle;'
INS_rev_fnct_moveInVehicle = { 
    private ["_id", "_unit", "_vehicle", "_turrets", "_sub_turrets"];
    
    scopeName "main";
    _unit = _this select 0;
    _vehicle = _this select 1;
    
	//if (_vehicle emptyPositions "Driver" > 0) exitWith { _unit action["getInDriver", _vehicle]; };
	if (_vehicle emptyPositions "Driver" > 0) exitWith { _unit moveInDriver _vehicle;};
	
	//if (_vehicle emptyPositions "Gunner" > 0) exitWith { _unit action["getInTurret", _vehicle, [0]]; };
	if (_vehicle emptyPositions "Gunner" > 0) exitWith { _unit moveInGunner _vehicle;};
    
    // Turret
    _turrets = configFile >> "CfgVehicles" >> typeof _vehicle >> "turrets";
	if (count _turrets > 0) then {
		for "_i" from 0 to (count _turrets) - 1 do {
			if (isNull (_vehicle turretUnit [_i])) then { _unit moveInTurret [_vehicle, [_i]]; breakOut "main";};
			
			_sub_turrets = _x >> "turrets";
			if (count _sub_turrets > 0) then {
				for "_j" from 0 to (count _sub_turrets) - 1 do {
					if (isNull (_vehicle turretUnit [_i, _j])) then { _unit moveInTurret [_vehicle, [_i, _j]]; breakOut "main";};
				};
			};
			_i = _i + 1;
		};
	};
	
	//if (_vehicle emptyPositions "Commander" > 0) exitWith { _unit action["getInCommander", _vehicle]; };
	if (_vehicle emptyPositions "Commander" > 0) exitWith { _unit moveInCommander _vehicle;};
    
    if (_vehicle emptyPositions "Cargo" > 0) exitWith { 
		_id = count (crew _vehicle - [driver _vehicle] - [gunner _vehicle] - [commander _vehicle]);
		//_unit action["getInCargo", _vehicle, _id];
		_unit moveInCargo [_vehicle, _id];
	};
    
};

// Check object is respawn locations
// Usage : 'object call INS_rev_fnct_isRespawnLocation;'
// Return : bool
INS_rev_fnct_isRespawnLocation = {
	private ["_location", "_respawnLocations"];
	
	_location = _this;
	_result = false;
	_respawnLocations = call INS_rev_fnct_get_respawn_locations;
	
	// Check location
	if (_location in _respawnLocations) then {
		_result = true;
	};

	_result
};

// Get respawn locations and alive players
// Usage : 'call INS_rev_fnct_getFriendly;'
// Return : array
INS_rev_fnct_getFriendly = {
    private ["_playerSide", "_respawn_locations", "_aliveFriendlyUnits", "_result", "_temp"];
    
    // Check respawn type
    if (INS_rev_respawn_type == 0) then {
		_aliveFriendlyUnits = call INS_rev_fnct_getAlivePlayers;
	} else {
		if (INS_rev_respawn_type == 1) then {
			_aliveFriendlyUnits = call INS_rev_fnct_getAliveFriendlyUnits; // Get alive friendly units
		} else {
			_aliveFriendlyUnits = call INS_rev_fnct_getAliveGroupUnits; // Get alive group units
		};
	};
	
	if (INS_rev_respawn_location == 2) then {
		_respawn_locations = [];
	} else {
		_respawn_locations = call INS_rev_fnct_get_respawn_locations;
	};
	
	_result = [];
	_result = _result + _aliveFriendlyUnits + _respawn_locations;
	
	if (count _result == 0) then {
		_result = [player];
	};
	
	// return value
	_result
};

// Get respawn locations
// Usage : 'call INS_rev_fnct_get_respawn_locations;'
// Return : array
INS_rev_fnct_get_respawn_locations = {
	 private ["_playerSide", "_location", "_respawn_locations", "_respawn_locations_result"];
    
    if (INS_rev_respawn_type == 0) then {
		_respawn_locations = INS_rev_list_of_respawn_locations_blufor + INS_rev_list_of_respawn_locations_opfor + INS_rev_list_of_respawn_locations_civ + INS_rev_list_of_respawn_locations_guer;
	} else {
		switch (side player) do {
			case west: { _respawn_locations = INS_rev_list_of_respawn_locations_blufor; };
			case east: { _respawn_locations = INS_rev_list_of_respawn_locations_opfor; };
			case civilian: { _respawn_locations = INS_rev_list_of_respawn_locations_civ; };
			case independent: { _respawn_locations = INS_rev_list_of_respawn_locations_guer; };
		};
	};
	
	// Check respawn location is alive
	_respawn_locations_result = [];
	{
		// String to Object
		if (!isNil _x) then {
			_location = call compile format["%1",_x];
			
			if (alive _location && !(_location in _respawn_locations_result)) then {
				_respawn_locations_result = _respawn_locations_result + [_location];
			};
		};
	} forEach _respawn_locations;
	
	_respawn_locations_result
};

// Get all players
// Usage : 'call INS_rev_fnct_getAllPlayers;'
// Return : array
INS_rev_fnct_getAllPlayers = {
	private ["_playableUnits", "_result"];
	
	_playableUnits = playableUnits;
	_result = [];
	
	// Check unit is player
	{
		if (isPlayer _x) then {
			_result = _result + [_x];
		};
	} forEach _playableUnits;
	
	_result
};

// Get all alive players
// Usage : 'call INS_rev_fnct_getAlivePlayers;'
// Return : array
INS_rev_fnct_getAlivePlayers = {
	private ["_allPlayers", "_result"];
	
	_allPlayers = call INS_rev_fnct_getAllPlayers;
	_result = [];
	
	// Check unit is alive
	{
		if (alive _x && !(_x getVariable "INS_rev_PVAR_is_unconscious")) then {
			_result = _result + [_x];
		};
	} forEach _allPlayers;
	
	_result
};

// Get all friendlfy players
// Usage : 'call INS_rev_fnct_getAllFriendlyUnits;'
// Return : array
INS_rev_fnct_getAllFriendlyUnits = {
	private ["_allPlayers", "_result", "_playerSide"];
	
	_allPlayers = call INS_rev_fnct_getAllPlayers;
	_playerSide = player getVariable "INS_rev_PVAR_playerSide";
	if (isNil "_playerSide") then {_playerSide = side player};
	_result = [];
	
	// Check unit is friendly
	{
		if (_x getVariable "INS_rev_PVAR_playerSide" == _playerSide) then {
			_result = _result + [_x];
		};
	} forEach _allPlayers;
	
	_result
};

// Get alive friendly players
// Usage : 'call INS_rev_fnct_getAliveFriendlyUnits;'
// Return : array
INS_rev_fnct_getAliveFriendlyUnits = {
	private ["_friendlyUnits", "_result"];
	
	_friendlyUnits = call INS_rev_fnct_getAllFriendlyUnits;
	_result = [];
	
	// Check unit is alive
	{
		if (alive _x && !(_x getVariable "INS_rev_PVAR_is_unconscious")) then {
			_result = _result + [_x];
		};
	} forEach _friendlyUnits;
	
	_result
};

// Get all group players
// Usage : 'call INS_rev_fnct_getAllGroupUnits;'
// Return : array
INS_rev_fnct_getAllGroupUnits = {
	private ["_playerGroup", "_groupUnits", "_result"];
	
	_playerGroup = player getVariable "INS_rev_PVAR_playerGroup";
	_groupUnits = units _playerGroup;
	_result = [];
	
	// Check is playable unit
	{
		if (isPlayer _x) then {
			_result = _result + [_x];
		};
	} forEach _groupUnits;
	
	_result
};

// Get alive group players
// Usage : 'call INS_rev_fnct_getAliveGroupUnits;'
// Return : array
INS_rev_fnct_getAliveGroupUnits = {
	private ["_playableUnits", "_result", "_playerSide"];
	
	_groupUnits = call INS_rev_fnct_getAllGroupUnits;
	_result = [];
	
	// Check is alive unit
	{
		if (alive _x && !(_x getVariable "INS_rev_PVAR_is_unconscious")) then {
			_result = _result + [_x];
		};
	} forEach _groupUnits;
	
	_result
};

// Check enemies near player
// Usage : '[unit] call INS_rev_fnct_is_near_enemy;'
// Return : bool
INS_rev_fnct_is_near_enemy = { 
	private ["_result", "_arr1", "_arr2", "_playerSide"];
	scopeName "main";
	
	_result = false;
	_arr1 = nearestObjects[_this select 0, ["LandVehicle"],INS_rev_near_enemy_distance]; 
	_arr2 = nearestObjects[_this select 0, ["Man"], INS_rev_near_enemy_distance];	
	_playerSide = player getVariable "INS_rev_PVAR_playerSide";
	
	{
		if (side _x != _playerSide && primaryWeapon _x != "" && alive _x && isNil {_x getVariable "INS_rev_PVAR_is_unconscious"}) exitWith {_result = true;};
		if (side _x != _playerSide && primaryWeapon _x != "" && alive _x && !(_x getVariable "INS_rev_PVAR_is_unconscious")) exitWith {_result = true;};
	} forEach _arr2;

	if (_result) exitWith {_result};
	
	for "_i" from 0 to (count _arr1 - 1) do { 
		{ 
			if (side _x != _playerSide && (!alive _x || !(_x getVariable "INS_rev_PVAR_is_unconscious"))) exitWith { 
				_result = true;
				breakTo "main"
			};
		} forEach (crew (_arr1 select _i)); 
	};
	
	_result
}; 

// Check friendly units are all dead
// Usage : 'call INS_rev_fnct_isAllDead;'
// Return : bool
INS_rev_fnct_isAllDead = {
	private ["_allUnits", "_result"];
	
	// Check respawn type
	switch (INS_rev_respawn_type) do {
		case 0: {
			_allUnits = call INS_rev_fnct_getAllPlayers;
		};
		case 1: {
			_allUnits = call INS_rev_fnct_getAllFriendlyUnits;
		};
		case 2: {
			_allUnits = call INS_rev_fnct_getAllGroupUnits;
		};
	};
	
	_result = true;
	{
		if (!(_x getVariable "INS_rev_PVAR_is_unconscious")) exitWith {_result = false;};
	} forEach _allUnits;
	
	_result
};

// Check is there near friendly units
// Usage : 'call INS_rev_fnct_isNearFriendly;'
// Return : bool
INS_rev_fnct_isNearFriendly = {
	private ["_units", "_nearUnits", "_nearFrieldy", "_range", "_result"];
	
	// If disalbed in config exit and return true
	if (INS_rev_near_friendly == 0) exitWith { true };
	
	_range = INS_rev_near_friendly_distance;
	_units = call INS_rev_fnct_getFriendly;
	_nearUnits = nearestObjects [player, ["CAManBase"], _range]; 
	_result = false;
	
	// Check friendly exists defined near area
	{
		if (_x in _units) exitWith {_result = true};
	} forEach _nearUnits; 
	
	_result
};

// Get dead units
// Usage : 'call INS_rev_FNC_get_dead_units;'
// Return : array
INS_rev_FNC_get_dead_units = {
	private ["_allUnits", "_result", "_isDead", "_isJIP"];
	
	// Check respawn type
	switch (INS_rev_respawn_type) do {
		case 0: {
			_allUnits = call INS_rev_fnct_getAllPlayers;
		};
		case 1: {
			_allUnits = call INS_rev_fnct_getAllFriendlyUnits;
		};
		case 2: {
			_allUnits = call INS_rev_fnct_getAllFriendlyUnits;
		};
	};
	
	_result = [];

	{
		_isDead = _x getVariable "INS_rev_PVAR_is_unconscious";
		if (isNil "_isDead") then {_isDead = false};
		
		_isTeleport = _x getVariable "INS_rev_PVAR_isTeleport";
		if (isNil "_isTeleport") then {_isTeleport = false};
		
		if ((!alive _x || _isDead) && (isPlayer _x) && !_isTeleport) then {
			_result = _result + [_x];
		};
	} forEach _allUnits;
	
	_result
};

// Check player can revive
// Usage : 'call INS_rev_fnct_can_revive;'
// Return : bool
INS_rev_fnct_can_revive = {
	if (INS_rev_allow_revive == 0) then {
		true
	} else {
		if ((INS_rev_allow_revive == 1) && getNumber (configFile >> "CfgVehicles" >> (typeOf player) >> "attendant") == 1) then {
			true
		} else {
			if (player in INS_rev_list_of_slots_who_can_revive) then {
				true
			} else {
				if (typeOf player in INS_rev_list_of_classnames_who_can_revive) then {
					true
				} else {
					false
				};
			};
		};
	};
};

// Set dead marker
// Usage : '[marker_array] call INS_rev_FNC_set_number_of_markers;'
// Return : array
INS_rev_FNC_set_number_of_markers = {
	private ["_markers", "_count", "_markerCount"];
	
	_markers = _this select 0;
	_count = _this select 1;
	_markerCount = count _markers;
	
	// Check current marker count
	switch true do {
		// If equal
		case (_markerCount == _count): {
			// exit
		};
		case (_markerCount > _count): {
			// Delete marker
			for "_x" from _count to (_markerCount - 1) do {
				_delMarker = _markers select _x;
				if (INS_rev_player_marker_serverSide) then {
					deleteMarker _delMarker; 
				} else {
					deleteMarkerLocal _delMarker; 
				};
				_markers = _markers - [_delMarker];
			};
		};
		case (_markerCount < _count): {
			// Create marker
			for "_x" from _markerCount to (_count - 1) do {
				if (INS_rev_player_marker_serverSide) then {
					_marker=createMarker [format ["dmarker%1",_x],[0,0,0]];
					_marker setMarkerType "mil_dot";
					_marker setMarkerColor "colorRed";
					_marker setMarkerSize [0.4, 0.4];
					_marker setMarkerAlpha 0;
				} else {
					_marker=createMarkerLocal [format ["dmarker%1",_x],[0,0,0]];
					_marker setMarkerTypeLocal "mil_dot";
					_marker setMarkerColorLocal "colorRed";
					_marker setMarkerSizeLocal [0.4, 0.4];
					_marker setMarkerAlphaLocal 0;
				};
				_markers set [_x,_marker];
			};
		};
	};
	
	_markers
};

// Add revive related action to unit
// Usage : '[variable, unit] call INS_rev_fnct_add_actions;'
INS_rev_fnct_add_actions = {
	private ["_unit", "_id_action", "_isTeleport"];
	scopeName "main";
	
	_unit = _this select 1;
	_isTeleport = _unit getVariable "INS_rev_PVAR_isTeleport";
	if (isNil "_isTeleport") then {_isTeleport = false};
	
	if (INS_rev_respawn_type != 0) then {
		private ["_playerSide", "_injuredSide"];

		_injuredSide = _unit getVariable "INS_rev_PVAR_playerSide";
		if (isNil "_injuredSide") then {_injuredSide = side _unit};

		_playerSide = player getVariable "INS_rev_PVAR_playerSide";
		if (isNil "_playerSide") then {_playerSide = side player};
		
		if (_injuredSide != _playerSide) exitWith {
			breakOut "main";
		};
	};

	if (!isNull _unit && !_isTeleport) then	{
		player reveal _unit;
		
		// Revive action
		_id_action = _unit addAction [STR_INS_rev_action_revive, "insurgency\modules\revive\act_revive.sqf", [], 10, false,	true, "", "player distance _target < 2 && !(player getVariable ""INS_rev_PVAR_is_unconscious"") && call INS_rev_fnct_can_revive && alive _target && isPlayer _target && (_target getVariable ""INS_rev_PVAR_is_unconscious"") && isNil {_target getVariable ""INS_rev_PVAR_who_taking_care_of_injured""}"];
		_unit setVariable ["INS_rev_id_action_revive", _id_action, false];
		
		// Drag body action
		_id_action = _unit addAction [STR_INS_rev_action_drag_body,	"insurgency\modules\revive\act_drag_body.sqf", [], 10, false, true, "", "player distance _target < 2 && !(player getVariable ""INS_rev_PVAR_is_unconscious"") && (INS_rev_can_drag_body == 1) && alive _target && isPlayer _target && (_target getVariable ""INS_rev_PVAR_is_unconscious"") && isNil {_target getVariable ""INS_rev_PVAR_who_taking_care_of_injured""}"];
		_unit setVariable ["INS_rev_id_action_drag_body", _id_action, false];
	};
};

// Remove revive related action
// Usage : '[variable, unit] call INS_rev_fnct_remove_actions;'
INS_rev_fnct_remove_actions = {
	private ["_unit"];
	scopeName "main";
	
	_unit = _this select 1;
	
	if (INS_rev_respawn_type != 0) then {
		private ["_playerSide", "_injuredSide"];
		_injuredSide = _unit getVariable "INS_rev_PVAR_playerSide";
		if (isNil "_injuredSide") then {_injuredSide = side _unit};

		_playerSide = player getVariable "INS_rev_PVAR_playerSide";
		if (isNil "_playerSide") then {_playerSide = side player};
		
		if (_injuredSide != _playerSide) exitWith {
			breakOut "main";
		};
	};
	
	// If unit is not null then remove actions
	if !(isNull _unit) then	{
		if !(isNil {_unit getVariable "INS_rev_id_action_revive"}) then {
			_unit removeAction (_unit getVariable "INS_rev_id_action_revive");
			_unit setVariable ["INS_rev_id_action_revive", nil, false];
		};
		
		if !(isNil {_unit getVariable "INS_rev_id_action_drag_body"}) then {
			_unit removeAction (_unit getVariable "INS_rev_id_action_drag_body");
			_unit setVariable ["INS_rev_id_action_drag_body", nil, false];
		};
	};
};

// Add unload action to vehicle
// Usage : '[unit, vehicle] call INS_rev_fnct_add_unload_action;'
INS_rev_fnct_add_unload_action = {
	private ["_vehicle", "_injured", "_id_action", "_loaded_list"];
	
	_vehicle = (_this select 1) select 0;
	_injured = (_this select 1) select 1;
	
	// If vehicle is not null then add actions.
	if (!isNull _vehicle) then	{
		player reveal _vehicle;
		
		// Unload action
		_id_action = _vehicle addAction [format[STR_INS_rev_action_unload_body, name _injured], "insurgency\modules\revive\act_unload_body.sqf",	[_vehicle, _injured], 10, false, true, "", ""];
		if !(isNil {_vehicle getVariable "INS_rev_GVAR_loaded_list"}) then {
			_loaded_list = _vehicle getVariable "INS_rev_GVAR_loaded_list";
		} else {
			_loaded_list = [];
		};
		
		if (count _loaded_list > 0) then {
			_loaded_list set [count _loaded_list, [_injured, _id_action]];
		} else {
			_loaded_list = [[_injured, _id_action]];
		};
		_vehicle setVariable ["INS_rev_GVAR_loaded_list", _loaded_list, false];
	};
};

// Remove unload action
// Usage : '[vehicle, unit] call INS_rev_fnct_remove_unload_action;'
INS_rev_fnct_remove_unload_action = {
	private ["_vehicle", "_injured", "_loaded_list", "_i"];
	
	_vehicle = (_this select 1) select 0;
	_injured = (_this select 1) select 1;
	
	// If vehicle is not null then remove actions
	if !(isNull _vehicle) then	{
		if !(isNil {_vehicle getVariable "INS_rev_GVAR_loaded_list"}) then {
			_loaded_list = _vehicle getVariable "INS_rev_GVAR_loaded_list";
			_i = 0;
			{
				if (_x select 0 == _injured) exitWith {
					_vehicle removeAction (_x select 1);
					_loaded_list set [_i, -1];
					_loaded_list = _loaded_list - [-1];
					if (count _loaded_list > 0) then {
						_vehicle setVariable ["INS_rev_GVAR_loaded_list", _loaded_list, false];
					} else {
						_vehicle setVariable ["INS_rev_GVAR_loaded_list", nil, false];
					};
				};
				_i = _i + 0;
			} forEach _loaded_list;
		};
	};
};

// Check player can respawn to camPlayer.
// Usage : 'call INS_rev_fnct_can_respawn;'
// Return : bool
INS_rev_fnct_can_respawn = {
	private ["_result"];
	
	_result = false;
	
	// If vehicle and not full
	if ([INS_rev_GVAR_camPlayer] call INS_rev_fnct_is_vehicle) then {
		if (!((vehicle INS_rev_GVAR_camPlayer) call INS_rev_fnct_vclisFull) && alive vehicle INS_rev_GVAR_camPlayer) then {
			_result = true;
		};
	} else {
		// If player
		if (vehicle INS_rev_GVAR_camPlayer isKindOf "Man" && alive vehicle INS_rev_GVAR_camPlayer) then {
			if (!(INS_rev_GVAR_camPlayer getVariable "INS_rev_PVAR_is_unconscious")) then {
				_result = true;
			};
		} else {
			if (INS_rev_GVAR_camPlayer call INS_rev_fnct_isRespawnLocation) then {
				_result = true;
			};
		};
	};
	
	_result
};

// Check player can respawn to camPlayer.
// Usage : 'call INS_rev_fnct_can_respawn;'
// Return : bool
INS_rev_fnct_can_respawn_except_vehicle = {
	private ["_result"];
	
	_result = false;
	
	// If vehicle and not full
	if ([INS_rev_GVAR_camPlayer] call INS_rev_fnct_is_vehicle) then {
		if (alive vehicle INS_rev_GVAR_camPlayer) then {
			_result = true;
		};
	} else {
		// If player
		if (vehicle INS_rev_GVAR_camPlayer isKindOf "Man" && alive vehicle INS_rev_GVAR_camPlayer) then {
			if (!(INS_rev_GVAR_camPlayer getVariable "INS_rev_PVAR_is_unconscious")) then {
				_result = true;
			};
		} else {
			if (INS_rev_GVAR_camPlayer call INS_rev_fnct_isRespawnLocation) then {
				_result = true;
			};
		};
	};
	
	_result
};

// Check object is vehicle.
// Usage : '[object] call INS_rev_fnct_is_vehicle;'
// Return : bool
INS_rev_fnct_is_vehicle = {
	private ["_result", "_veh"];
	
	_result = false;
	_veh = _this select 0;
	
	// Check object is vehicle
	if ((vehicle _veh isKindOf "LandVehicle" || vehicle _veh isKindOf "Air" || vehicle _veh isKindOf "Ship")) then {
		_result = true;
	};
	
	_result
};


// Get camera attach coordinate
// Usage : 'call INS_rev_fnct_get_camAttachCoords;'
// Return : array
INS_rev_fnct_get_camAttachCoords = {
	private ["_result", "_xC", "_yC", "_zC"];
	
	_xC = INS_rev_GVAR_camRange * sin(INS_rev_GVAR_theta) * cos(INS_rev_GVAR_phi);
	_yC = INS_rev_GVAR_camRange * sin(INS_rev_GVAR_theta) * sin(INS_rev_GVAR_phi);
	_zC = INS_rev_GVAR_camRange * cos(INS_rev_GVAR_theta);
	_result = [_xC,_yC,_zC];
	
	_result
};

// Reset dead camera
// Usage : 'call INS_rev_fnct_reset_camera;'
INS_rev_fnct_reset_camera = {
	private ["_friendly", "_camAttachCoords", "_camStaticCoords"];
	
	// If not exitst INS_rev_GVAR_camPlayer, reset INS_rev_GVAR_camPlayer
	if (isNull INS_rev_GVAR_camPlayer) then { 
		_friendly = call INS_rev_fnct_getFriendly;
		INS_rev_GVAR_camPlayer = _friendly select 0;
	};
	
	// Set distance
	if ((vehicle INS_rev_GVAR_camPlayer) isKindOf "Man") then {
		INS_rev_GVAR_camRange = 5;
	} else {
		INS_rev_GVAR_camRange = (sizeOf typeOf vehicle INS_rev_GVAR_camPlayer) max 5;
	};
	
	// Set angle and coordinate
	INS_rev_GVAR_theta =  74;
	INS_rev_GVAR_phi   = -90;
	_camAttachCoords = call INS_rev_fnct_get_camAttachCoords;
	_camStaticCoords = [((getPos vehicle INS_rev_GVAR_camPlayer) select 0) + (_camAttachCoords select 0),((getPos vehicle INS_rev_GVAR_camPlayer) select 1) + (_camAttachCoords select 1),((getPos vehicle INS_rev_GVAR_camPlayer) select 2) + (_camAttachCoords select 2)];
	
	// attatch camera to target
	if (INS_rev_GVAR_camPlayer isKindOf "Man" || [INS_rev_GVAR_camPlayer] call INS_rev_fnct_is_vehicle) then {
		INS_rev_GVAR_dead_camera = "camera" camCreate _camStaticCoords;
		INS_rev_GVAR_dead_camera cameraEffect ["INTERNAL", "Back"];
		INS_rev_GVAR_dead_camera CamSetTarget vehicle INS_rev_GVAR_camPlayer;
		INS_rev_GVAR_dead_camera camCommit 0;
		INS_rev_GVAR_dead_camera attachTo [vehicle INS_rev_GVAR_camPlayer, _camAttachCoords];
	} else {
		INS_rev_GVAR_dead_camera = "camera" camCreate _camStaticCoords;
		INS_rev_GVAR_dead_camera cameraEffect ["INTERNAL", "Back"];
		INS_rev_GVAR_dead_camera CamSetTarget INS_rev_GVAR_camPlayer;
		INS_rev_GVAR_dead_camera camSetRelPos _camAttachCoords;
		INS_rev_GVAR_dead_camera camCommit 0;
	};
	
	titleText [" ", "Black in", 2];
};

// Set respawn tag
// Usage : 'call INS_rev_fnct_respawn_tag;'
INS_rev_fnct_respawn_tag = {
	private ["_unit", "_leftTime", "_leftTimeText", "_lifeTime", "_name", "_txt", "_ctrlText", "_color", "_respawnDelay"];
	
	// If player turn on map exit
	if INS_rev_GVAR_camMap exitWith {};
	
	_unit = _this select 0;
	_respawnDelay = call INS_rev_fnct_getRespawnDelay;
	_leftTime = round ((_unit getVariable "INS_rev_PVAR_deadTime") + _respawnDelay - time);
	if (INS_rev_life_time > 0) then {
		_lifeTime = round (INS_RES_GVAR_killed_time + INS_rev_life_time - time);
	};
	
	// Set name
	if (!(INS_rev_GVAR_camPlayer call INS_rev_fnct_isRespawnLocation)) then {
		_name = name INS_rev_GVAR_camPlayer;
	} else {
		_name = toUpper (format["%1", INS_rev_GVAR_camPlayer]);
	};
	
	// If restrict respawn
	If (INS_rev_respawn_location == 1 && !(INS_rev_GVAR_camPlayer call INS_rev_fnct_isRespawnLocation)) exitWith {
		cutRsc["Rtags", "PLAIN",5]; 	
		_color = "#ff6347";
		_leftTimeText = "";
		if (_leftTime > 0) then {_leftTimeText = format["<br/>(can respawn in %1 sec)",_leftTime];};
		_txt = format["%1 (Spectating)<br/>(You can only respawn at the base)%2", _name, _leftTimeText];
		_ctrlText = (uiNamespace getVariable 'TAGS_HUD') displayCtrl 64434;
		_ctrlText ctrlSetStructuredText parseText format[
			"<t color='%2' shadow='1' shadowColor='#000000'>%1</t><br/><br/><t color='#808080' shadow='1' shadowColor='#000000'>Left Arrow: Previous Unit<br/>Right Arrow: Next Unit<br/>Backspace: Virtual Ammobox</br></t>",
			_txt,
			_color
		];
	};
	
	// If vehicle cannot move
	if ([vehicle INS_rev_GVAR_camPlayer] call INS_rev_fnct_is_vehicle && !canMove INS_rev_GVAR_camPlayer) exitWith {
		cutRsc["Rtags", "PLAIN",5]; 	
		_color = "#ff6347";
		_leftTimeText = "";
		if (_leftTime > 0) then {_leftTimeText = format["<br/>(can respawn in %1 sec)",_leftTime];};
		_txt = format["%1 (Spectating)<br/>(cannot respawn at damaged vehicle)%2", _name, _leftTimeText];
		_ctrlText = (uiNamespace getVariable 'TAGS_HUD') displayCtrl 64434;
		_ctrlText ctrlSetStructuredText parseText format[
			"<t color='%2' shadow='1' shadowColor='#000000'>%1</t><br/><br/><t color='#808080' shadow='1' shadowColor='#000000'>Left Arrow: Previous Unit<br/>Right Arrow: Next Unit<br/>Backspace: Virtual Ammobox</br></t>",
			_txt,
			_color
		];
	};
	
	// If left respawn delay time
	if (_leftTime > 0) exitWith {
		cutRsc["Rtags", "PLAIN",5]; 	
		_color = "#ff6347";
		_txt = format["%1 (Spectating)<br/>(can respawn in %2 sec)", _name, _leftTime];
		_ctrlText = (uiNamespace getVariable 'TAGS_HUD') displayCtrl 64434; 	
		_ctrlText ctrlSetStructuredText parseText format["<t color='%2' shadow='1' shadowColor='#000000'>%1</t><br/><br/><t color='#808080' shadow='1' shadowColor='#000000'>Left Arrow: Previous Unit<br/>Right Arrow: Next Unit<br/>Backspace: Virtual Ammobox</br></t>", _txt, _color];
	};
	
	// If vehicle is not full and not respawn location
	if (vehicle INS_rev_GVAR_camPlayer call INS_rev_fnct_vclisFull) exitWith {
		cutRsc["Rtags", "PLAIN",5]; 	
		_color = "#ff6347";
		_leftTimeText = "";
		if (_leftTime > 0) then { _leftTimeText = format["<br/>(can respawn in %1 sec)", _leftTime]; };
		_txt = format["%1 (Spectating)<br/>(cannot spawn in vehicle if full)%2", _name, _leftTimeText];
		_ctrlText = (uiNamespace getVariable 'TAGS_HUD') displayCtrl 64434;
		_ctrlText ctrlSetStructuredText parseText format["<t color='%2' shadow='1' shadowColor='#000000'>%1</t><br/><br/><t color='#808080' shadow='1' shadowColor='#000000'>Left Arrow: Previous Unit<br/>Right Arrow: Next Unit<br/>Backspace: Virtual Ammobox</br></t>", _txt, _color];
	};
	
	// If you can respawn
	if (INS_rev_life_time > 0) then {
		if (_lifeTime > 0) then {
			_txt = format["%1 (Press Enter to Spawn)<br/>(Dead in: %2)", _name, _lifeTime];
		} else {
			_txt = format["%1 (Press Enter to Spawn)<br/></t><t color='#ff6347' shadow='1' shadowColor='#000000'>(You cannot be revived)", _name];
		};
	} else {
		_txt = format["%1 (Press Enter to Spawn)", _name];
	};
	if (!(INS_rev_GVAR_camPlayer call INS_rev_fnct_isRespawnLocation)) then { _color = "#7ba151"; } else { _color = "#6775cf"; };
	
	// Apply respawn tag
	cutRsc["Rtags", "PLAIN",5]; 	
	_ctrlText = (uiNamespace getVariable 'TAGS_HUD') displayCtrl 64434;	
	_ctrlText ctrlSetStructuredText parseText format["<t color='%2' shadow='1' shadowColor='#000000'>%1</t><br/><br/><t color='#808080' shadow='1' shadowColor='#000000'>Left Arrow: Previous Unit<br/>Right Arrow: Next Unit<br/>Backspace: Virtual Ammobox</br></t>", _txt, _color];
};

// Set respawn tag
// Usage(thread) : '_sctipt = unit spawn INS_rev_fnct_dead_camera;'
INS_rev_fnct_dead_camera = {
	private ["_unit", "_camPlayer", "_respawnDelay", "_KH", "_MH1", "_MH2", "_to_be_Respawned_in", "_doRespawn", "_camAttachCoords", "_vehicle", "_ctrlText", "_deadTime", "_condition", "_isTeleport"];
	disableSerialization;
	
	// Set parameter to variable
	_unit = _this;
	
	_camPlayer = objNull;
	INS_rev_GVAR_camMap	= false;
	INS_rev_GVAR_camPlayer = objNull;
	_respawnDelay = call INS_rev_fnct_getRespawnDelay;
	
	call INS_rev_fnct_reset_camera; // Initialize dead camera
	call INS_rev_fnct_disalble_thermal_cam;

	showcinemaborder false;	// Disable cinema border
	
	// Initialize variable
	_camPlayer = INS_rev_GVAR_camPlayer;
	_vehicle = vehicle INS_rev_GVAR_camPlayer;
	_to_be_Respawned_in = round (time + 5);
	_doRespawn = false;
	INS_rev_GVAR_enterSpawn	= false;
	
	// Wait until player be respawned
	waitUntil {player getVariable "INS_rev_PVAR_is_unconscious"};
	_unit = player;
	
	// Set revive delay time
	_isTeleport = _unit getVariable "INS_rev_PVAR_isTeleport";
	// If not teleport
	if (!_isTeleport) then {
		_deadTime = _unit getVariable "INS_rev_PVAR_deadTime";
		
		if (isNil "_deadTime") then {
			_deadTime = time;
		} else {;
			// Delay time is not expired
			if (_deadTime + _respawnDelay < time) then {
				_deadTime = time;
			};
		};
	} else { _deadTime = time - _respawnDelay; };

	_unit setVariable ["INS_rev_PVAR_deadTime", _deadTime, false];
	
	// Keyboard and mouse hooking
	waitUntil { !(isNull (findDisplay 46)) };
	
	_KH = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call INS_rev_fnct_onKeyPress;"];
	_MH1 = (findDisplay 46) displayAddEventHandler ["MouseMoving", "_this call INS_rev_fnct_onMouseMove;"];
	_MH2 = (findDisplay 46) displayAddEventHandler ["MouseZChanged", "_this call INS_rev_fnct_onMouseWheel;"];
	
	_condition = _unit getVariable "INS_rev_PVAR_is_unconscious";

	// Loop while player is unconscious
	while {_condition && alive _unit} do {
		// If changed camera target, reset camera
		if (isNull INS_rev_GVAR_camPlayer || INS_rev_GVAR_camPlayer != _camPlayer) then {
			call INS_rev_fnct_reset_camera;
			
			// Reset variables
			_camPlayer = INS_rev_GVAR_camPlayer;
			_vehicle = vehicle INS_rev_GVAR_camPlayer;
			_to_be_Respawned_in	= round (time + 5);
			INS_rev_GVAR_enterSpawn	= false;
		};
		
		// Display respawn tag
		if ((INS_rev_GVAR_camPlayer call INS_rev_fnct_isRespawnLocation || alive INS_rev_GVAR_camPlayer) && !INS_rev_GVAR_enterSpawn) then {
			// Reset player's to be respawned time
			_to_be_Respawned_in = round (time + 5);
			
			// If player get in vehicle then change deadCamera's coordinate
			if (_vehicle != vehicle INS_rev_GVAR_camPlayer) then { 
				_vehicle   = vehicle INS_rev_GVAR_camPlayer;
				_camAttachCoords = call INS_rev_fnct_get_camAttachCoords;
				INS_rev_GVAR_dead_camera attachTo [_vehicle, _camAttachCoords];
				INS_rev_GVAR_dead_camera camSetTarget _vehicle;	
				INS_rev_GVAR_dead_camera camCommit 0;
			};
			
			[_unit] call INS_rev_fnct_respawn_tag; // Update respawn tag
		};
		
		// Display to be respawned timeout tag
		if (_camPlayer == INS_rev_GVAR_camPlayer && INS_rev_GVAR_enterSpawn) then {
			// If not player can respawn to camPlayer then exit
			if !(call INS_rev_fnct_can_respawn) exitWith {
				INS_rev_GVAR_enterSpawn = false; _to_be_Respawned_in = round (time + 5); // Reset variable
			};
			
			// Display respawn tag
			cutRsc["Rtags", "PLAIN",5];
			_ctrlText = (uiNamespace getVariable 'TAGS_HUD') displayCtrl 64434; 	
			_ctrlText ctrlSetStructuredText parseText format["<t color='#7ba151' shadow='1' shadowColor='#000000'>Respawning in %1</t><br/><br/><t color='#808080' shadow='1' shadowColor='#000000'>Left Arrow: Previous Unit<br/>Right Arrow: Next Unit<br/>Backspace: Virtual Ammobox</br></t>", round (_to_be_Respawned_in - time)]; 
			
			// If to be respawned timeout is over, do respawn (End loop)
			if (round (_to_be_Respawned_in - time) <= 0) exitWith {				
				_unit setVariable ["INS_rev_PVAR_is_unconscious", false, true]; // Reset variable
				_doRespawn = true;
			};
		};
		
		// If player choose respawn to INS_rev_GVAR_camPlayer (Exit loop)
		if (_doRespawn) exitWith {
			// If player can respawn to camPlayer
			if (call INS_rev_fnct_can_respawn) then {
				if ([INS_rev_GVAR_camPlayer] call INS_rev_fnct_is_vehicle && !(vehicle INS_rev_GVAR_camPlayer call INS_rev_fnct_vclisFull)) then {
					if (!isNil "INS_rev_GVAR_is_loaded" && {INS_rev_GVAR_is_loaded} && INS_rev_medevac == 1) then {
						_unit action ["EJECT", vehicle _unit];
						sleep 0.5;
					};

					[_unit, (vehicle INS_rev_GVAR_camPlayer)] call INS_rev_fnct_moveInVehicle;
				} else {
					if (!isNil "INS_rev_GVAR_is_loaded" && {INS_rev_GVAR_is_loaded} && INS_rev_medevac == 1) then {
						_unit action ["EJECT", vehicle _unit];
						sleep 0.5;
					};

					_unit setDir getDir INS_rev_GVAR_camPlayer;
					_unit setPosATL getPosATL INS_rev_GVAR_camPlayer;
					
					[_unit, "AmovPercMstpSrasWrflDnon"] call INS_rev_fnct_switchMove;
				};
				_doRespawn = false;
			} else {
				[_unit, "AmovPercMstpSrasWrflDnon"] call INS_rev_fnct_switchMove;
			};
		};
		
		// If INS_rev_GVAR_camPlayer is dead, reset camera
		if !(call INS_rev_fnct_can_respawn_except_vehicle) then {
		 	INS_rev_GVAR_camPlayer = objNull; 
		};
		
		// If left respawn delay time, check allDead and nearest friendly
		if (_deadTime + _respawnDelay > time) then {
			if (INS_rev_near_friendly  == 1) then {
				if (!(call INS_rev_fnct_isNearFriendly) && _deadTime + 10 < time) then {
					_unit setVariable ["INS_rev_PVAR_deadTime", _deadTime - _respawnDelay, true];
				};
			};
			if (INS_rev_all_dead_respawn == 1) then {
				if (call INS_rev_fnct_isAllDead) then {
					_unit setVariable ["INS_rev_PVAR_deadTime", _deadTime - _respawnDelay, true];
				};
			};
		};

		sleep 0.2;
		_condition = _unit getVariable "INS_rev_PVAR_is_unconscious";

	};
	
	// Remove display eventhander
	(findDisplay 46) displayRemoveEventHandler ["KeyDown", _KH];
	(findDisplay 46) displayRemoveEventHandler ["MouseMoving", _MH1];
	(findDisplay 46) displayRemoveEventHandler ["MouseZChanged", _MH2];
	
	// Terminate dead camera
	openMap [false, false];
	INS_rev_GVAR_dead_camera cameraEffect ["terminate", "back"];
	camDestroy INS_rev_GVAR_dead_camera;
	"dynamicBlur" ppEffectEnable true;
	"dynamicBlur" ppEffectAdjust [6];
	"dynamicBlur" ppEffectCommit 0;
	"dynamicBlur" ppEffectAdjust [0.0];
	"dynamicBlur" ppEffectCommit 2;
};

// KeyDown event handler
INS_rev_fnct_onKeyPress = {
	private ["_handled", "_list", "_id", "_size", "_key", "_leftTime", "_respawnDelay"];
	scopeName "main";
	
	_key = _this select 1;
	_handled = false;
	_respawnDelay = call INS_rev_fnct_getRespawnDelay;
	
	// if not alive player then exit function.
	if (!alive player) exitWith {};
	
	if (_key in (actionKeys 'showmap')) then {
		//if isNull respawnCamera exitWith {};
		INS_rev_GVAR_camMap = !INS_rev_GVAR_camMap;
		openMap [INS_rev_GVAR_camMap, INS_rev_GVAR_camMap];
		if INS_rev_GVAR_camMap then {
			mapAnimAdd [0, 0.1, getPosATL INS_rev_GVAR_camPlayer];
			mapAnimCommit;
		};
	};
	
	switch _key do {
		case 17: { //W key
			if (speed player == 0 && lifeState player != "UNCONSCIOUS") then { detach player; };
		};

		case 28: { //Enter key
			_leftTime = round ((player getVariable "INS_rev_PVAR_deadTime") + _respawnDelay - time);
			if ( _leftTime > 0) exitWith {};
			if (INS_rev_respawn_location == 1 && !(INS_rev_GVAR_camPlayer call INS_rev_fnct_isRespawnLocation)) exitWith {};
			if ([INS_rev_GVAR_camPlayer] call INS_rev_fnct_is_vehicle && !canMove INS_rev_GVAR_camPlayer) exitWith {};
			if (isNull INS_rev_GVAR_dead_camera || INS_rev_GVAR_camMap ) exitWith {};
			if (INS_rev_GVAR_enterSpawn) exitWith { INS_rev_GVAR_enterSpawn = false;};
			if (INS_rev_near_enemy == 1) then {
				if ((INS_rev_GVAR_camPlayer call INS_rev_fnct_isRespawnLocation) && !([INS_rev_GVAR_camPlayer] call INS_rev_fnct_is_vehicle)) exitWith {};
				if ([INS_rev_GVAR_camPlayer] call INS_rev_fnct_is_near_enemy) exitWith { 
					titleText [format["There's an enemy near '%1'. You cannot respawn now.", name INS_rev_GVAR_camPlayer], "PLAIN"];
					breakOut "main";
				};
			};
			if (!INS_rev_GVAR_enterSpawn && (INS_rev_GVAR_camPlayer call INS_rev_fnct_isRespawnLocation)) exitWith { INS_rev_GVAR_enterSpawn = true;};
			if (vehicle INS_rev_GVAR_camPlayer call INS_rev_fnct_vclisFull) exitWith {};
			//if (lifeState INS_rev_GVAR_camPlayer == "UNCONSCIOUS") exitWith {};	
			if !INS_rev_GVAR_enterSpawn then { INS_rev_GVAR_enterSpawn = true;};
		};
		
		case 31: { //S key
			if (speed player == 0 && lifeState player != "UNCONSCIOUS") then { detach player; };
		};
		
		case 49: { //N key
			if (isNil "INS_rev_GVAR_camNVG") then { INS_rev_GVAR_camNVG = true; };
			camUseNVG INS_rev_GVAR_camNVG;
			INS_rev_GVAR_camNVG = !INS_rev_GVAR_camNVG;
		};
		
		
		case 203: { //Left
			_list = call INS_rev_fnct_getFriendly;
			_size = count _list;
			_id = _list find INS_rev_GVAR_camPlayer;
			_id = _id - 1;
			if (_id < 0) then { _id = _size - 1; };
			INS_rev_GVAR_camPlayer =  _list select _id;
		};
		
		
		case 205: { //Right 
			_list = call INS_rev_fnct_getFriendly;
			_size = count _list;
			_id = _list find INS_rev_GVAR_camPlayer;
			_id = _id + 1;
			if (_id == _size) then { _id = 0; };
			INS_rev_GVAR_camPlayer = _list select _id;
		};	
	};
	
	_handled
};

// MouseMove event handler
INS_rev_fnct_onMouseMove = {
	private ["_xS", "_yS", "_xC", "_yC", "_zC", "_camAttachCoords"];
	
	// If not exist dead camera, exit
	if (isNull INS_rev_GVAR_dead_camera ) exitWith {};	

	_yS = (_this select 1);	
	_xS = (_this select 2);
	
	// Calculate theta
	INS_rev_GVAR_theta = INS_rev_GVAR_theta - _xS;
	if (INS_rev_GVAR_theta < 20) then {INS_rev_GVAR_theta = 20;};
	if (INS_rev_GVAR_theta > 160) then {INS_rev_GVAR_theta = 160;};
	
	// Calculate phi
	INS_rev_GVAR_phi = INS_rev_GVAR_phi - _yS;
	if (INS_rev_GVAR_phi < -270) then {INS_rev_GVAR_phi = -270;};
	if (INS_rev_GVAR_phi > 90) then {INS_rev_GVAR_phi = 90;};
	
	// Calculate cam attach coordinate
	_camAttachCoords = call INS_rev_fnct_get_camAttachCoords;
	
	// If camPlayer is man or vehicle then attach camera.
	if (INS_rev_GVAR_camPlayer isKindOf "Man" || [INS_rev_GVAR_camPlayer] call INS_rev_fnct_is_vehicle) then {
		INS_rev_GVAR_dead_camera attachTo [vehicle INS_rev_GVAR_camPlayer, _camAttachCoords];
	} else {
		// Or set camera
		detach INS_rev_GVAR_dead_camera;
		INS_rev_GVAR_dead_camera CamSetTarget vehicle INS_rev_GVAR_camPlayer;
		INS_rev_GVAR_dead_camera camSetRelPos _camAttachCoords;
		INS_rev_GVAR_dead_camera camCommit 0.5;
	};
};

// MouseWheel event handler
INS_rev_fnct_onMouseWheel = {
	private ["_xC", "_yC", "_zC", "_vC", "_camAttachCoords"];
	
	// If not exist dead camera, exit
	if (isNull INS_rev_GVAR_dead_camera) exitWith {};
	
	// Calculate cam range
	_vC = (_this select 1);
	if (_vC > 0) then {
		INS_rev_GVAR_camRange = INS_rev_GVAR_camRange - 1;
	} else {
		INS_rev_GVAR_camRange = INS_rev_GVAR_camRange + 1;
	};
	if (INS_rev_GVAR_camRange < 2) then {INS_rev_GVAR_camRange = 2;};
	
	// Calculate cam attach coordinate
	_camAttachCoords = call INS_rev_fnct_get_camAttachCoords;
	
	// If camPlayer is man or vehicle then attach camera.
	if (INS_rev_GVAR_camPlayer isKindOf "Man" || [INS_rev_GVAR_camPlayer] call INS_rev_fnct_is_vehicle) then {
		INS_rev_GVAR_dead_camera attachTo [vehicle INS_rev_GVAR_camPlayer, _camAttachCoords];
	} else {
		// Or set camera
		detach INS_rev_GVAR_dead_camera;
		INS_rev_GVAR_dead_camera CamSetTarget vehicle INS_rev_GVAR_camPlayer;
		INS_rev_GVAR_dead_camera camSetRelPos _camAttachCoords;
		INS_rev_GVAR_dead_camera camCommit 0.5;
	};
};

INS_rev_fnct_onKilled = { // On killed event handler
	if (_this select 0 != player) exitWith {};
	
	terminate INS_rev_thread_exec_wait_revive; // Terminate existing thread
	
	player setVariable ["INS_rev_PVAR_is_unconscious", false, true];
	player setVariable ["INS_rev_PVAR_is_dead", false, true];
	if (INS_rev_life_time > 0) then {
		INS_RES_GVAR_killed_time = time;
		INS_rev_GVAR_is_lifeTime_over = false;
	};
	
	INS_rev_thread_exec_wait_revive = [] spawn INS_rev_fnct_onKilled_process; // Spawn new thread
};

INS_rev_fnct_onKilled_process = { // Process onKilled event
	private ["_position_before_dead", "_altitude_ATL_before_dead", "_direction_before_dead", "_magazines_before_dead", "_weapons_before_dead", "_player", "_condition", "_loadout", "_who_taking_care_of_injured"];

	_position_before_dead = getPos INS_rev_GVAR_body_before_dead;
	_altitude_ATL_before_dead = getPosATL INS_rev_GVAR_body_before_dead select 2;
	_direction_before_dead = getDir INS_rev_GVAR_body_before_dead;
	
	// Remove dead body's actions
	INS_rev_GVAR_end_unconscious = INS_rev_GVAR_body_before_dead;
	publicVariable "INS_rev_GVAR_end_unconscious";
	["INS_rev_GVAR_end_unconscious", INS_rev_GVAR_end_unconscious] spawn INS_rev_fnct_remove_actions;
	INS_rev_GVAR_body_before_dead setVariable ["INS_rev_PVAR_is_unconscious", false, true];
	INS_rev_GVAR_body_before_dead setVariable ["INS_rev_PVAR_who_taking_care_of_injured", nil, true];

	sleep round (playerRespawnTime - 1); // Wait respawn camera
	terminate INS_rev_thread_dead_camera; // Terminate existing dead camera thread
	INS_rev_thread_dead_camera = player spawn INS_rev_fnct_dead_camera; // Start dead camera thread

	waitUntil {alive player};
	_player = player;
	
	// Set player do not allow damage and cannot be attacked
	[_player, false] call INS_rev_fnct_allowDamage;
	[_player, "AinjPpneMstpSnonWrflDnon"] call INS_rev_fnct_switchMove;

	INS_rev_GVAR_start_unconscious = _player;
	publicVariable "INS_rev_GVAR_start_unconscious";

	_player setVariable ["INS_rev_PVAR_is_unconscious", true, true];
	_player setVariable ["INS_rev_PVAR_playerSide", INS_rev_GVAR_body_before_dead getVariable "INS_rev_PVAR_playerSide", true];
	_player setVariable ["INS_rev_PVAR_playerGroup", INS_rev_GVAR_body_before_dead getVariable "INS_rev_PVAR_playerGroup", true];
	_player setVariable ["INS_rev_PVAR_playerGroupColor", INS_rev_GVAR_body_before_dead getVariable "INS_rev_PVAR_playerGroupColor", true];
	_player setVariable ["INS_rev_PVAR_who_taking_care_of_injured", nil, true];
	_player setVariable ["INS_rev_revived", false, true];
	
	// If player not used teleport, remove dead body
	if !(_player getVariable "INS_rev_PVAR_isTeleport") then {
		waitUntil {INS_rev_GVAR_body_before_dead != _player};
		deleteVehicle INS_rev_GVAR_body_before_dead;
	};

	_player setVelocity [0, 0, 0];
	_player setDir _direction_before_dead;
	_player setPos [_position_before_dead select 0, _position_before_dead select 1, _altitude_ATL_before_dead - (_position_before_dead select 2)];
	
	// Reset variable
	INS_rev_GVAR_body_before_dead = _player;
	_condition = _player getVariable "INS_rev_PVAR_is_unconscious";

	while {_condition} do {
		_who_taking_care_of_injured = _player getVariable "INS_rev_PVAR_who_taking_care_of_injured";
			
		// If somebody is taking care of you
		if !(isNil "_who_taking_care_of_injured") then {
			// If the one who taking care of you is not alive.
			if (isNull _who_taking_care_of_injured || !alive _who_taking_care_of_injured || !isPlayer _who_taking_care_of_injured) then	{
				// Reset player's state
				detach _player;
				if !(isNull _who_taking_care_of_injured) then {detach _who_taking_care_of_injured;};
				_player switchMove "AinjPpneMstpSnonWrflDnon";
				_player setVariable ["INS_rev_PVAR_who_taking_care_of_injured", nil, true];
			};
		};
		
		// Check MEDEVAC vehicle
		if (INS_rev_medevac == 1) then {
			if (_player != vehicle _player) then {
				if (alive vehicle _player) then {
					INS_rev_GVAR_is_loaded = true;
					INS_rev_GVAR_loaded_vehicle = vehicle _player;
				} else {
					[] call INS_rev_fnct_unload;
				};
			};
			
			if (_player == vehicle _player && !isNil "INS_rev_GVAR_is_loaded" && {INS_rev_GVAR_is_loaded}) then {
				[] call INS_rev_fnct_unload;
			};
		};
		
		// Check Life Time
		if (INS_rev_life_time > 0) then {
			if (!INS_rev_GVAR_is_lifeTime_over) then {
				private "_lifeTime";
				_lifeTime = round (INS_RES_GVAR_killed_time + INS_rev_life_time);
				
				if (time > _lifeTime) then {
					INS_rev_GVAR_is_lifeTime_over = true;
					
					// Remove revive action
					INS_rev_GVAR_end_unconscious = _player;
					publicVariable "INS_rev_GVAR_end_unconscious";
					["INS_rev_GVAR_end_unconscious", INS_rev_GVAR_end_unconscious] spawn INS_rev_fnct_remove_actions;
					
					_player setVariable ["INS_rev_PVAR_is_dead", true, true];
				};
			};
		};
		
		sleep 0.3;

		_condition = _player getVariable "INS_rev_PVAR_is_unconscious";
		[_player] call INS_rev_fnct_prevent_drown;

	};
	
	sleep 0.2;
	
	
	_player selectWeapon (primaryWeapon _player); // Select primary weapon

	// Remove revive action
	INS_rev_GVAR_end_unconscious = _player;
	publicVariable "INS_rev_GVAR_end_unconscious";		
	["INS_rev_GVAR_end_unconscious", INS_rev_GVAR_end_unconscious] spawn INS_rev_fnct_remove_actions;
	
	// Remove unload action
	if (!isNil "INS_rev_GVAR_is_loaded" && {INS_rev_GVAR_is_loaded} && INS_rev_medevac == 1) then {
		INS_rev_GVAR_del_unload = [INS_rev_GVAR_loaded_vehicle, _player];
		publicVariable "INS_rev_GVAR_del_unload";
		["INS_rev_GVAR_del_unload", INS_rev_GVAR_del_unload] spawn INS_rev_fnct_remove_unload_action;
		
		INS_rev_GVAR_is_loaded = false;
		INS_rev_GVAR_loaded_vehicle = nil;
	};
	
	
	// Set player allow damage and can be attacked
	[_player, true] call INS_rev_fnct_allowDamage;
	
	// Reset variable
	isJIP = false;
	_player setVariable ["INS_rev_PVAR_isTeleport", false, true];
	_player setVariable ["INS_rev_PVAR_is_dead", false, true];
};

// Unload player from vehicle
// Usage : 'call INS_rev_fnct_unload;'
INS_rev_fnct_unload = {
	private ["_player"];
	
	_player = player;
	
	// Remove unload action
	INS_rev_GVAR_del_unload = [INS_rev_GVAR_loaded_vehicle, _player];
	publicVariable "INS_rev_GVAR_del_unload";
	["INS_rev_GVAR_del_unload", INS_rev_GVAR_del_unload] spawn INS_rev_fnct_remove_unload_action;
	
	// Unload
	_player action ["EJECT", vehicle _player];
	[_player, "AinjPpneMstpSnonWrflDnon"] call INS_rev_fnct_switchMove;
	while {animationState _player != "AinjPpneMstpSnonWrflDnon"} do {
		sleep 0.1;
		[_player, "AinjPpneMstpSnonWrflDnon"] call INS_rev_fnct_switchMove;
	};
	
	INS_rev_GVAR_is_loaded = false;
	INS_rev_GVAR_loaded_vehicle = nil;
};

// Teleport to teammate action
INS_rev_fnct_init_teleport_to_teamate = {
	INS_rev_GVAR_teleportToTeam = player addAction ["<t color='#7ba151'>Teleport To Teammate</t>", [], 10, false, true, "",	""];
	sleep 120;
	player removeAction INS_rev_GVAR_teleportToTeam;
	isJIP = false;
	player setVariable ["INS_rev_PVAR_isTeleport", false, true];
};

// Check dragging is finished
// Usage : 'call INS_rev_fnct_is_finished_dragging;'
// Return : bool
INS_rev_fnct_is_finished_dragging = {
	private "_result";
	
	_result = true;
	
	if (!isNil "INS_rev_GVAR_do_release_body" && {!INS_rev_GVAR_do_release_body}) then {
		if (!isNull _player && alive _player && !isNull _injured && alive _injured && isPlayer _injured && _injured getVariable "INS_rev_PVAR_is_unconscious") then {
			if (animationState _player == "acinpknlmwlksraswrfldb" || animationState _player == "acinpknlmstpsraswrfldnon") then {
				_result = false;
			};
		};
	};
	
	_result
};

// Check dragging is finished
// Usage : 'call INS_rev_fnct_is_finished_dragging;'
// Return : bool
INS_rev_fnct_is_finished_dragging_prone = {
	private ["_result", "_prone_moves"];
	
	_result = true;
	_prone_moves = ["amovppnemstpsraswrfldnon", "amovppnemrunslowwrfldf", "amovppnemsprslowwrfldfl", "amovppnemsprslowwrfldfr", "amovppnemrunslowwrfldb", "amovppnemsprslowwrfldbl", "amovppnemsprslowwrfldr", "amovppnemstpsraswrfldnon_turnl", "amovppnemstpsraswrfldnon_turnr", "amovppnemrunslowwrfldl", "amovppnemrunslowwrfldr", "amovppnemsprslowwrfldb", "amovppnemrunslowwrfldbl", "amovppnemsprslowwrfldl", "amovppnemsprslowwrfldbr"];
	
	if (!isNil "INS_rev_GVAR_do_release_body" && {!INS_rev_GVAR_do_release_body}) then {
		if (!isNull _player && alive _player && !isNull _injured && alive _injured && isPlayer _injured && _injured getVariable "INS_rev_PVAR_is_unconscious") then {
			if (animationState _player in _prone_moves) then {
				_result = false;
			};
		};
	};
	
	_result
};

// Get group color index
// Usage : '[unit] call FNC_GET_GROUP_COLOR_INDEX;'
// Return : number
INS_rev_fnct_get_group_color_index = {
	private ["_phoneticCode", "_found", "_index", "_result", "_i", "_j"];
	
	_unit = _this select 0;
	_phoneticCode = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf"];
	_found = false;
	_index = 0;
	
	// Find group name
	{
		for "_i" from 1 to 4 do {
		 	for "_j" from 1 to 3 do {
		 		_groupName = format["%1 %2-%3", _x, _i, _j];
		 		if (format["b %1",_groupName] == str(group _unit) || format["o %1",_groupName] == str(group _unit)) exitWith {
		 			_found = true;
		 		};
		 		_index = _index + 1;
			};
			if (_found) exitWith {};
		};
		if (_found) exitWith {};
	} forEach _phoneticCode;
	
	// If not found, return 0
	if (!_found) then {
		_result = 0;
	} else {
		_result = _index % 10;
	};
	
	_result
};

// Get group color
// Usage : '[unit] call FNC_GET_GROUP_COLOR;'
// Return : string
INS_rev_fnct_get_group_color = {
	private ["_unit", "_colors", "_colorIndex", "_result"];
	
	// Set varialble
	_unit = _this select 0;
	_colors = ["ColorGreen", "ColorYellow", "ColorOrange", "ColorPink", "ColorBrown", "ColorKhaki", "ColorBlue", "ColorRed", "ColorBlack", "ColorWhite"];
	_colorIndex = [_unit] call INS_rev_fnct_get_group_color_index;
	
	// Set color
	_result = _colors select _colorIndex;
	
	_result
};

// Get respawn delay time
// Usage : 'call INS_rev_fnct_getRespawnDelay;'
// Return : int
INS_rev_fnct_getRespawnDelay = {
	private ["_result", "_playerSide"];

	_result = INS_rev_respawn_delay;
	switch (side player) do {
		case west: {
			if (!isNil {INS_rev_respawn_delay_blufor}) then {_result = INS_rev_respawn_delay_blufor;};
		};

		case east: {
			if (!isNil {INS_rev_respawn_delay_opfor}) then {_result = INS_rev_respawn_delay_opfor;};
		};

		case civilian: {
			if (!isNil {INS_rev_respawn_delay_civ}) then {_result = INS_rev_respawn_delay_civ;};
		};

		case independent: {
			if (!isNil {INS_rev_respawn_delay_guer}) then {_result = INS_rev_respawn_delay_guer;};
		};
	};
	
	_result;
};

// Damage event handler
// Usage : 'player addEventHandler ["HandleDamage", {_this call INS_rev_fnct_clientHD}];'
// Return : damage
INS_rev_fnct_clientHD = {
	private ["_unit", "_dam"];
	_unit = _this select 0;
	_dam = _this select 2;
	
	if (!alive _unit || {_dam == 0}) exitWith {
		_dam
	};
	if (_unit getVariable "INS_rev_PVAR_is_unconscious") exitWith {0};

	BIS_hitArray = _this; BIS_wasHit = true;
	_dam
};

// Block respawn button
// Usage : 'spawn INS_rev_fnct_respawnBlock;'
INS_rev_fnct_respawnBlock = {
	private ["_ctrl", "_enCtrl"];
	disableSerialization;
	
	while {true} do {
		waitUntil {!isNull (findDisplay 49)};

		_ctrl = (findDisplay 49) displayCtrl 1010; //respawn control
		_ctrl ctrlEnable false;
		
		waitUntil {sleep 0.12; isNull (findDisplay 49)};
	};
};

// Prevent drown
// Usage : '[unit] call INS_rev_fnct_prevent_drown;'
INS_rev_fnct_prevent_drown = {
	private "_unit";
	_unit = _this select 0;
	_unit setOxygenRemaining 1;
};

// Check unit is underwater
// Usage(thread) : '[unit] call INS_rev_fnct_is_underwater;'
// Return : boot
INS_rev_fnct_is_underwater = {
	private ["_unit","_result"];
	_unit = _this select 0;
	_result = underwater _unit;
	_result
};

// Disable thermal cam
// Usage : 'call INS_rev_fnct_disalble_thermal_cam;'
INS_rev_fnct_disalble_thermal_cam = {
	false setCamUseTi 0;
};

// Draw respawn locations marker
// Usage : 'spawn INS_rev_fnct_displayRespawnLocationMarker;'
INS_rev_fnct_displayRespawnLocationMarker = {
	private ["_respawnLocations", "_markers", "_markersUpdate", "_marker", "_color", "_type", "_colorArray", "_markerTypeArray", "_vehicleType"];

	_respawnLocations = [] call INS_rev_fnct_get_respawn_locations;
	_colorArray = ["ColorOrange", "ColorYellow", "ColorGreen", "ColorPink", "ColorBrown", "ColorKhaki", "ColorBlue", "ColorRed", "ColorBlack", "ColorWhite"];
	_markerTypeArray = ["mil_marker", "mil_flag", "mil_dot", "mil_box", "mil_triangle", "mil_destroy", "mil_circle"];
	_markers = [];
	
	_color = _colorArray select INS_rev_respawnLocationMarkerColor;
	
	while { true } do {
		_respawnLocations = [] call INS_rev_fnct_get_respawn_locations;
		_markersUpdate = [];

		{
			_marker = format["lmarker%1",_x];
			_markersUpdate = _markersUpdate + [_marker];

			if !(_marker in _markers) then {
				_marker=createMarkerLocal [format ["lmarker%1",_x],[0,0,0]];
				switch true do {
					case (vehicle _x isKindOf "Helicopter"): {_type = "n_air"};
					case (vehicle _x isKindOf "Plane"): {_type = "n_plane"};
					case (vehicle _x isKindOf "Car"): {_type = "n_motor_inf"};
					case (vehicle _x isKindOf "Tank"): {_type = "n_armor"};
					case (vehicle _x isKindOf "Ship"): {_type = "n_motor_inf"};
					default { _type = _markerTypeArray select INS_rev_respawnLocationMarkerType; };
				};

				_marker setMarkerTypeLocal _type;
				_marker setMarkerColorLocal _color;
				_marker setMarkerSizeLocal [0.7, 0.7];
				_marker setMarkerPosLocal getPos _x;
				_marker setMarkerTextLocal toUpper format["%1", _x];
				_markers = _markers + [_marker];
			};
			_marker setMarkerPosLocal getPos _x;
		} forEach _respawnLocations;
		
		{
			if !(_x in _markersUpdate) then {
				_markers = _markers - [_x];
				deleteMarkerLocal _x;
			};
		} forEach _markers;

		sleep 1;
	};
};

INS_rev_fnct_init_completed = true;
