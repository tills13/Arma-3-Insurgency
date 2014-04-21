private ["_vehicle","_menu_lift_shown","_nearest","_id","_pos","_npos"];

INS_plane_loadIntoCargo = {
	INS_plane_attachPoints = [["ac_130X_desert", [0, 5, 5]], ["I_Heli_Transport_02_F", [0, 4, -1]]];
	getAttachPoint = {
		private["_veh", "_return"];
		_veh = typeOf _this;
		_return = [0, 0, 0];

		{
			if (_x select 0 == _veh) then { _return = _x select 1; };
		} forEach INS_plane_attachPoints;

		_return
	};

	_carrier = _this select 0;
	_caller = _this select 1;
	_veh = (_carrier call INS_plane_getNearestObjects) select 0;
	hint parseText format["Loading <t color='#7ba151'>%1</t> into %2 cargo", vehicleVarName _veh, vehicleVarName _carrier];

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
};

INS_plane_unloadFromCargo = {
	_carrier = _this select 0;
	_caller = _this select 1;
	_index = _this select 3;
	_cargo = _carrier getVariable "cargo";
	_veh = _cargo select _index;
	hint parseText format["Unloading <t color='#7ba151'>%1</t> from %2 cargo", vehicleVarName _veh, vehicleVarName _carrier];

	if ((getpos _carrier select 2) > 3) then {
		_dir = getDir _carrier;
		_newX = (getPos _carrier select 0) + (sin _dir * -25);
		_newY = (getPos _carrier select 1) + (cos _dir * -25);
		_newPos = [_newX, _newY, (getPos _carrier select 2)];

		_veh setPos _newPos; 
		detach _veh;
		sleep 1;

		_chute = "ParachuteBigWest_EP1" createVehicle (getpos _veh);
		_chute setpos (_veh ModelToWorld [0,0,3]);
		_veh attachTo [_chute, [0, 0, 0]];
	} else {
		_dir = getDir _carrier;
		_newX = (getPos _carrier select 0) + (sin _dir * -25);
		_newY = (getPos _carrier select 1) + (cos _dir * -25);
		_newPos = [_newX, _newY, (getPos _carrier select 2)];

		_veh setPos _newPos; 
		detach _veh;
	};

	_cargo = _cargo - [_veh];
	_carrier setVariable ["cargo", _cargo, true];
	call INS_plane_showMenu;
};

INS_plane_getNearestObjects = {
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

INS_plane_showMenu = {
	private ["_carrier", "_cargo"];
	_carrier = _this select 0;
	_carrier removeAction (_carrier getVariable "_INS_PLANE_UNLOAD_AID");
	_cargo = _carrier getVariable "cargo";

	_INS_PLANE_TITLE_AID = _carrier getVariable "_INS_PLANE_TITLE_AID";
	if (!isNil "_INS_PLANE_TITLE_AID") then { _carrier removeAction _INS_PLANE_TITLE_AID; };
	_INS_PLANE_TITLE_AID = _carrier addAction ["<t color='#6775cf'>Unload Vehicle: </t>", "", nil, 1.5, false, true];
	_carrier setVariable ["_INS_PLANE_TITLE_AID", _INS_PLANE_TITLE_AID];

	_INS_PLANE_MENU_ITEMS = _carrier getVariable "_INS_PLANE_MENU_ITEMS";
	if (!isNil "_INS_PLANE_MENU_ITEMS") then {
		{
			_carrier removeAction _x;
		} forEach _INS_PLANE_MENU_ITEMS;
	};

	_INS_PLANE_MENU_ITEMS = [];
	_index = 0;
	{
		_INS_PLANE_MENU_ITEMS = _INS_PLANE_MENU_ITEMS + [_carrier addAction [format["  Unload %1", vehicleVarName _x], INS_plane_unloadFromCargo, _index, 1.5, false, false]];
		_index = _index + 1;
	} forEach _cargo;
	_carrier setVariable ["_INS_PLANE_MENU_ITEMS", _INS_PLANE_MENU_ITEMS];

	_INS_PLANE_CANCEL_AID = _carrier getVariable "_INS_PLANE_CANCEL_AID";
	if (!isNil "_INS_PLANE_CANCEL_AID") then { _carrier removeAction _INS_PLANE_CANCEL_AID; };
	_INS_PLANE_CANCEL_AID = _carrier addAction ["  <t color='#ff6347'>Cancel Unload</t>", INS_plane_hideMenu, nil, 1.5, false, false];
	_carrier setVariable ["_INS_PLANE_CANCEL_AID", _INS_PLANE_CANCEL_AID];
};

INS_plane_hideMenu = {
	private ["_carrier"];
	_carrier = _this select 0;
	_carrier removeAction (_carrier getVariable "_INS_PLANE_TITLE_AID");
	_carrier removeAction (_carrier getVariable "_INS_PLANE_CANCEL_AID");

	{
		_carrier removeAction _x;
	} forEach (_carrier getVariable "_INS_PLANE_MENU_ITEMS");
	_carrier setVariable ["_INS_PLANE_MENU_ITEMS", []];

	_INS_PLANE_UNLOAD_AID = _carrier addAction ["Unload Vehicle", INS_plane_showMenu, nil, 1.6, false, false, "", "count (_target getVariable 'cargo') != 0"];
	_carrier setVariable ["_INS_PLANE_UNLOAD_AID", _INS_PLANE_UNLOAD_AID];
};

INS_plane_cargoSize = {
	private ["_veh"];
	_carrier = _this;
	_cargoSize = 0;

	{
		for "_i" from 0 to count INS_plane_lift_vehicles do {
			if (_x == ((INS_plane_lift_vehicles select _i) select 0)) then { _cargoSize = _cargoSize + ((INS_plane_lift_vehicles select _i) select 1) };
		};
	} forEach (_carrier getVariable "cargo");

	_cargoSize
};

INS_plane_lift_vehicles = [["B_MRAP_01_gmg_F", 10], ["B_MRAP_01_F", 10], ["B_MRAP_01_hmg_F", 10], ["B_Quadbike_01_F", 1], ["B_Truck_01_transport_F", 50], ["B_Truck_01_covered_F", 50]];

if (not local player) exitWith {};
_carrier = _this select 0;

_INS_PLANE_LOAD_AID = _carrier addAction ["Load Vehicle", INS_plane_loadIntoCargo, nil, 1.6, false, true, "", "count (_target call INS_plane_getNearestObjects) != 0"];
_INS_PLANE_UNLOAD_AID = _carrier addAction ["Unload Vehicle", INS_plane_showMenu, nil, 1.6, false, false, "", "count (_target getVariable 'cargo') != 0"];

_carrier setVariable ["_INS_PLANE_LOAD_AID", _INS_PLANE_LOAD_AID];
_carrier setVariable ["_INS_PLANE_UNLOAD_AID", _INS_PLANE_UNLOAD_AID];

_carrier setVariable ["cargo", [], true];
_carrier setVariable ["cargoSize", 50, true];