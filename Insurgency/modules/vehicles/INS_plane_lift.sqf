private ["_vehicle","_menu_lift_shown","_nearest","_id","_pos","_npos"];

INS_plane_loadIntoCargo = {
	_plane = _this select 0;
	_caller = _this select 1;
	_veh = (_plane call INS_plane_getNearestObjects) select 0;
	hint parseText format["Loading <t color='#7ba151'>%1</t> into AC130 cargo", vehicleVarName _veh];

	sleep 0.3;
	_veh attachTo [_plane, [0, 5, -4.5]];
	_veh addEventHandler ["GetOut", {
	    _vehicle = _this select 0; 
	    _position = _this select 1;
	    _unit = _this select 2;

	    //_unit moveInCargo _plane;
	}];

	INS_plane_inCargo = INS_plane_inCargo + [_veh];
};

INS_plane_unloadFromCargo = {
	_plane = _this select 0;
	_caller = _this select 1;
	_index = _this select 3;
	_veh = INS_plane_inCargo select _index;
	hint parseText format["Unloading <t color='#7ba151'>%1</t> from AC130 cargo", vehicleVarName _veh];

	if ((getpos _plane select 2) > 3) then {
		_dir = getDir _plane;
		_newX = (getPos _plane select 0) + (sin _dir * -25);
		_newY = (getPos _plane select 1) + (cos _dir * -25);
		_newPos = [_newX, _newY, (getPos _plane select 2)];

		_veh setPos _newPos; 
		detach _veh;
		sleep 1;

		_chute = "ParachuteMediumWest" createVehicle getpos _cargo;
		_chute setpos (_veh ModelToWorld [0,0,3]);
		_cargo attachTo [_chute, [0, 0, 0]];
	} else {
		_dir = getDir _plane;
		_newX = (getPos _plane select 0) + (sin _dir * -25);
		_newY = (getPos _plane select 1) + (cos _dir * -25);
		_newPos = [_newX, _newY, (getPos _plane select 2)];

		_veh setPos _newPos; 
		detach _veh;
	};

	INS_plane_inCargo = INS_plane_inCargo - [_veh];
	call INS_plane_showMenu;
};

INS_plane_getNearestObjects = {
	private ["_plane"];
	_plane = _this;
	_nearObjs = nearestObjects [_plane, ['LandVehicle'], 20];

	_objs = [];
	{
		if !(_x in INS_plane_inCargo) then { _objs = _objs + [_x] };
	} forEach _nearObjs;

	_objs
};

INS_plane_showMenu = {
	private ["_plane"];
	_plane = _this select 0;
	_plane removeAction INS_PLANE_UNLOAD_AID;

	if (!isNil "INS_PLANE_TITLE_AID") then {_plane removeAction INS_PLANE_TITLE_AID;};
	INS_PLANE_TITLE_AID = _plane addAction ["<t color='#6775cf'>Unload Vehicle: </t>", "", nil, 1.5, false, true];

	if (!isNil "INS_PLANE_MENU_ITEMS") then {
		{
			_plane removeAction _x;
		} forEach INS_PLANE_MENU_ITEMS;
	};

	INS_PLANE_MENU_ITEMS = [];
	_index = 0;
	{
		INS_PLANE_MENU_ITEMS = INS_PLANE_MENU_ITEMS + [_plane addAction [format["  Unload %1", vehicleVarName _x], INS_plane_unloadFromCargo, _index, 1.5, false, false]];
		_index = _index + 1;
	} forEach INS_plane_inCargo;

	if (!isNil "INS_PLANE_CANCEL_AID") then {_plane removeAction INS_PLANE_CANCEL_AID;};
	INS_PLANE_CANCEL_AID = _plane addAction ["  <t color='#ff6347'>Cancel Unload</t>", INS_plane_hideMenu, nil, 1.5, false, false];
};

INS_plane_hideMenu = {
	private ["_plane"];
	_plane = _this select 0;
	_plane removeAction INS_PLANE_TITLE_AID;
	_plane removeAction INS_PLANE_CANCEL_AID;

	{
		_plane removeAction _x;
		INS_PLANE_MENU_ITEMS = INS_PLANE_MENU_ITEMS - [_x];
	} forEach INS_PLANE_MENU_ITEMS;

	INS_PLANE_UNLOAD_AID = _plane addAction ["Unload Vehicle", INS_plane_showMenu, nil, 1.6, false, false, "", "count INS_plane_inCargo != 0"];
};

INS_plane_cargoSize = {
	private ["_veh"];
	_cargoSize = 0;

	{
		for "_i" from 0 to count INS_plane_lift_vehicles do {
			if (_x == ((INS_plane_lift_vehicles select _i) select 0)) then { _cargoSize = _cargoSize + ((INS_plane_lift_vehicles select _i) select 1) };
		};
	} forEach INS_plane_inCargo;

	_cargoSize
};

INS_plane_lift_vehicles = [["B_MRAP_01_gmg_F", 10], ["B_MRAP_01_F", 10], ["B_MRAP_01_hmg_F", 10], ["B_Quadbike_01_F", 1], ["B_Truck_01_transport_F", 50], ["B_Truck_01_covered_F", 50]];

if (not local player) exitWith {};
_plane = _this select 0;

INS_plane_inCargo = [];
INS_plane_maxCargo = 50;

INS_PLANE_LOAD_AID = _plane addAction ["Load Vehicle", INS_plane_loadIntoCargo, nil, 1.6, false, true, "", "count (_target call INS_plane_getNearestObjects) != 0"];
INS_PLANE_UNLOAD_AID = _plane addAction ["Unload Vehicle", INS_plane_showMenu, nil, 1.6, false, false, "", "count INS_plane_inCargo != 0"];