private ["_vehicle","_menu_lift_shown","_nearest","_id","_pos","_npos"];

INS_cargo_loadIntoCargo = {
	private ["_name"];
	INS_cargo_attachPoints = [["ac_130X_desert", [0, 5, 5]], ["I_Heli_Transport_02_F", [0, 4, -1]], ["C130J_Cargo", [0, 4, -2.5]]];
	getAttachPoint = {
		private["_veh", "_return"];
		_veh = typeOf _this;
		_return = [0, 0, 0];

		{
			if (_x select 0 == _veh) then { _return = _x select 1; };
		} forEach INS_cargo_attachPoints;

		_return
	};

	_carrier = _this select 0;
	_caller = _this select 1;
	_veh = (_carrier call INS_cargo_getNearestObjects) select 0;
	
	_currentCargoSize = _carrier call INS_cargo_getCurrentCargoSize;
	_maxCargoSize = _carrier getVariable "maxCargoSize";

	if (_currentCargoSize < _maxCargoSize) then {
		_name = vehicleVarName _veh;
		if (_name == "") then { _name = typeOf _veh };
		hint parseText format["Loading <t color='#7ba151'>%1</t> into %2 cargo", _name, vehicleVarName _carrier];

		sleep 0.3;
		_veh attachTo [_carrier, _carrier call getAttachPoint];
		_veh addEventHandler ["GetOut", {
		    _vehicle = _this select 0; 
		    _position = _this select 1;
		    _unit = _this select 2;

		    //_unit moveInCargo _carrier;
		}];

		_cargo = _carrier getVariable "cargo";
		_cargo = _cargo + [_veh];
		_carrier setVariable ["cargo", _cargo, true];

		_carrier removeAction (_carrier getVariable "_INS_CARGO_LOAD_AID");
		_carrier removeAction (_carrier getVariable "_INS_CARGO_UNLOAD_AID");
		_INS_CARGO_LOAD_AID = _carrier addAction [format["Load Vehicle (%1/%2)", _carrier call INS_cargo_getCurrentCargoSize, _carrier getVariable "maxCargoSize"], INS_cargo_loadIntoCargo, nil, 1.6, false, true, "", "count (_target call INS_cargo_getNearestObjects) != 0"];
		_INS_CARGO_UNLOAD_AID = _carrier addAction [format ["Unload Vehicle (%1)", count (_carrier getVariable "cargo")], INS_cargo_showMenu, nil, 1.6, false, false, "", "count (_target getVariable 'cargo') != 0"];
		_carrier setVariable ["_INS_CARGO_LOAD_AID", _INS_CARGO_LOAD_AID];
		_carrier setVariable ["_INS_CARGO_UNLOAD_AID", _INS_CARGO_UNLOAD_AID];
	} else {
		hint parseText format["<t color='#7ba151'>%1</t> cargo full", vehicleVarName _carrier];
	};
};

INS_cargo_unloadAllFromCargo = {
	_carrier = _this select 0;
	_cargo = _carrier getVariable "cargo";

	{
		[_carrier, "", "", 0] call INS_cargo_unloadFromCargo;
		sleep 1;
	} forEach _cargo;
};

INS_cargo_unloadFromCargo = {
	private ["_name"];
	_carrier = _this select 0;
	_index = _this select 3;
	_cargo = _carrier getVariable "cargo";
	_veh = _cargo select _index;
	_name = vehicleVarName _veh;
	if (_name == "") then { _name = typeOf _veh };
	hint parseText format["Unloading <t color='#7ba151'>%1</t> from %2 cargo", _name, vehicleVarName _carrier];

	if ((getpos _carrier select 2) > 3) then {
		_dir = getDir _carrier;
		_newX = (getPos _carrier select 0) + (sin _dir * -20);
		_newY = (getPos _carrier select 1) + (cos _dir * -20);
		_newPos = [_newX, _newY, (getPos _carrier select 2)];

		_veh setPos _newPos;
		detach _veh;

		_chute = "ParachuteBigWest_EP1" createVehicle (getpos _veh);

		_location = _veh ModelToWorld [0, 0, 0];
		_chute setposATL (_veh ModelToWorld [0, 0, 3]);
		_veh attachTo [_chute, [0, 0, 0]];
	} else {
		_dir = getDir _carrier;
		_newX = (getPos _carrier select 0) + (sin _dir * -20);
		_newY = (getPos _carrier select 1) + (cos _dir * -20);
		_newPos = [_newX, _newY, 1];

		detach _veh;

		sleep 0.1;
		_veh setPosATL _newPos;
	};

	_cargo = _cargo - [_veh];
	_carrier setVariable ["cargo", _cargo, true];
	call INS_cargo_showMenu;
};

INS_cargo_getNearestObjects = {
	private ["_carrier", "_cargo"];
	_carrier = _this;
	_nearObjs = nearestObjects [_carrier, ['LandVehicle', 'AirVehicle'], 20];
	_cargo = _carrier getVariable "cargo";

	_objs = [];
	{
		if !(_x in _cargo) then { _objs = _objs + [_x] };
	} forEach _nearObjs;

	_objs
};

INS_cargo_showMenu = {
	private ["_carrier", "_cargo"];
	_carrier = _this select 0;
	_carrier removeAction (_carrier getVariable "_INS_CARGO_UNLOAD_AID");
	_cargo = _carrier getVariable "cargo";

	_INS_CARGO_TITLE_AID = _carrier getVariable "_INS_CARGO_TITLE_AID";
	if (!isNil "_INS_CARGO_TITLE_AID") then { _carrier removeAction _INS_CARGO_TITLE_AID; };
	_INS_CARGO_TITLE_AID = _carrier addAction ["<t color='#6775cf'>Unload Vehicle: </t>", "", nil, 1.5, false, true];
	_carrier setVariable ["_INS_CARGO_TITLE_AID", _INS_CARGO_TITLE_AID];

	_INS_CARGO_MENU_ITEMS = _carrier getVariable "_INS_CARGO_MENU_ITEMS";
	if (!isNil "_INS_CARGO_MENU_ITEMS") then {
		{
			_carrier removeAction _x;
		} forEach _INS_CARGO_MENU_ITEMS;
	};

	_INS_CARGO_MENU_ITEMS = [];
	_index = 0;
	{	
		_name = vehicleVarName _x;
		if (_name == "") then { _name = typeOf _x };
		_INS_CARGO_MENU_ITEMS = _INS_CARGO_MENU_ITEMS + [_carrier addAction [format["  Unload %1 (%2)", _name, count crew _x], INS_cargo_unloadFromCargo, _index, 1.5, false, false]];
		_index = _index + 1;
	} forEach _cargo;
	_carrier setVariable ["_INS_CARGO_MENU_ITEMS", _INS_CARGO_MENU_ITEMS];

	_carrier removeAction (_carrier getVariable "_INS_CARGO_LOAD_AID");
	_INS_CARGO_LOAD_AID = _carrier addAction [format["Load Vehicle (%1/%2)", _carrier call INS_cargo_getCurrentCargoSize, _carrier getVariable "maxCargoSize"], INS_cargo_loadIntoCargo, nil, 1.6, false, true, "", "count (_target call INS_cargo_getNearestObjects) != 0"];
	_carrier setVariable ["_INS_CARGO_LOAD_AID", _INS_CARGO_LOAD_AID];

	_INS_CARGO_CANCEL_AID = _carrier getVariable "_INS_CARGO_CANCEL_AID";
	if (!isNil "_INS_CARGO_CANCEL_AID") then { _carrier removeAction _INS_CARGO_CANCEL_AID; };
	_INS_CARGO_CANCEL_AID = _carrier addAction ["  <t color='#ff6347'>Cancel Unload</t>", INS_cargo_hideMenu, nil, 1.5, false, false];
	_carrier setVariable ["_INS_CARGO_CANCEL_AID", _INS_CARGO_CANCEL_AID];
};

INS_cargo_hideMenu = {
	private ["_carrier"];
	_carrier = _this select 0;
	_carrier removeAction (_carrier getVariable "_INS_CARGO_TITLE_AID");
	_carrier removeAction (_carrier getVariable "_INS_CARGO_CANCEL_AID");

	{
		_carrier removeAction _x;
	} forEach (_carrier getVariable "_INS_CARGO_MENU_ITEMS");
	_carrier setVariable ["_INS_CARGO_MENU_ITEMS", []];

	_carrier removeAction (_carrier getVariable "_INS_CARGO_LOAD_AID");
	_carrier removeAction (_carrier getVariable "_INS_CARGO_UNLOAD_AID");
	_INS_CARGO_LOAD_AID = _carrier addAction [format["Load Vehicle (%1/%2)", _carrier call INS_cargo_getCurrentCargoSize, _carrier getVariable "maxCargoSize"], INS_cargo_loadIntoCargo, nil, 1.6, false, true, "", "count (_target call INS_cargo_getNearestObjects) != 0"];
	_INS_CARGO_UNLOAD_AID = _carrier addAction [format ["Unload Vehicle (%1)", count (_carrier getVariable "cargo")], INS_cargo_showMenu, nil, 1.6, false, false, "", "count (_target getVariable 'cargo') != 0"];
	_carrier setVariable ["_INS_CARGO_LOAD_AID", _INS_CARGO_LOAD_AID];
	_carrier setVariable ["_INS_CARGO_UNLOAD_AID", _INS_CARGO_UNLOAD_AID];
};

INS_cargo_vehicles = [["B_MRAP_01_gmg_F", 10], ["B_MRAP_01_F", 10], ["B_MRAP_01_hmg_F", 10], ["B_Quadbike_01_F", 1], ["B_Truck_01_transport_F", 50], ["B_Truck_01_covered_F", 50]];
INS_cargo_getCurrentCargoSize = {
	private ["_veh", "_i"];
	_carrier = _this;
	_cargoSize = 0;

	{	
		player sideChat str _x;
		player sideChat typeOf _x;
		//player sideChat (INS_cargo_vehicles select _i);
		for "_i" from 0 to count INS_cargo_vehicles do {
			if (typeOf _x == ((INS_cargo_vehicles select _i) select 0)) then { _cargoSize = _cargoSize + ((INS_cargo_vehicles select _i) select 1) };
		};
	} forEach (_carrier getVariable "cargo");

	_cargoSize
};

if (not local player) exitWith {};
_carrier = _this select 0;
_carrier setVariable ["cargo", [], true];
_carrier setVariable ["maxCargoSize", 50, true];

_INS_CARGO_LOAD_AID = _carrier addAction [format["Load Vehicle (%1/%2)", _carrier call INS_cargo_getCurrentCargoSize, _carrier getVariable "maxCargoSize"], INS_cargo_loadIntoCargo, nil, 1.6, false, true, "", "count (_target call INS_cargo_getNearestObjects) != 0"];
_INS_CARGO_UNLOAD_AID = _carrier addAction [format ["Unload Vehicle (%1)", count (_carrier getVariable "cargo")], INS_cargo_showMenu, nil, 1.6, false, false, "", "count (_target getVariable 'cargo') != 0"];

_carrier setVariable ["_INS_CARGO_LOAD_AID", _INS_CARGO_LOAD_AID];
_carrier setVariable ["_INS_CARGO_UNLOAD_AID", _INS_CARGO_UNLOAD_AID];