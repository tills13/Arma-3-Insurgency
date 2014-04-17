private ["_vehicle","_menu_lift_shown","_nearest","_id","_pos","_npos"];


INS_heli_attach = {
	_vehicle = _this select 0;
	_caller = _this select 1;
	_id = _this select 2;

	if (_caller == driver _vehicle) then {
		_vehicle removeAction _id;
		INS_heli_ATTACHED = true;	
	};
};

INS_heli_release = {
	_vehicle = _this select 0;
	_caller = _this select 1;
	_id = _this select 2;

	if (_caller == driver _vehicle) then {
		_vehicle removeAction _id;
		INS_heli_RELEASED = true;
	};
};

INS_fnc_HelperTextRed = {"<t color='#ff6347'>" + _this + "</t>"};
INS_fnc_HelperTextBlue = {"<t color='#6775cf'>" + _this + "</t>"};
INS_fnc_HelperTextGreen = {"<t color='#7ba151'>" + _this + "</t>"};

if (not local player) exitWith {};
_vehicle = _this select 0;

INS_heli_ATTACHED = false;
INS_heli_RELEASED = false;
_menu_lift_shown = false;
INS_heli_attatchedList = [];
_nearest = objNull;
_id = -1;

sleep 0.1;

waitUntil { (alive _vehicle) && (alive player) && (driver _vehicle == player) };
while { (alive _vehicle) && (alive player) && (driver _vehicle == player) } do {
	if ((driver _vehicle) == player) then {
		_pos = getPos _vehicle;
		
		diag_log format["%1, %2", INS_heli_ATTACHED, _pos];
		if (!INS_heli_ATTACHED && (_pos select 2 > 2.5) && (_pos select 2 < 8)) then {
			_nearest = nearestObjects [_vehicle, ["LandVehicle"], 50];
			_nearest = if (count _nearest > 0) then {_nearest select 0} else {ObjNull};
			sleep 0.1;

			if (!(isNull _nearest)) then {
				_nearest_pos = getPos _nearest;
				_nx = _nearest_pos select 0;
				_ny = _nearest_pos select 1;
				_px = _pos select 0;
				_py = _pos select 1;
				if ((_px <= _nx + 6 && _px >= _nx - 6) && (_py <= _ny + 6 && _py >= _ny - 6)) then {
					if (!_menu_lift_shown) then {
						_id = _vehicle addAction ["Lift Vehicle" call INS_fnc_HelperTextGreen, INS_heli_attach];
						_menu_lift_shown = true;
					};
				} else {
					_nearest = objNull;
					if (_menu_lift_shown) then {
						_vehicle removeAction _id;
						_menu_lift_shown = false;
					};
				};
			};
		} else {
			if (_menu_lift_shown) then {
				_vehicle removeAction _id;
				_menu_lift_shown = false;
			};
			
			sleep 0.1;
			
			if (isNull _nearest) then {
				INS_heli_ATTACHED = false;
				INS_heli_RELEASED = false;
			} else {
				if (INS_heli_ATTACHED) then {
					_release_id = _vehicle addAction ["Drop Vehicle" call INS_fnc_HelperTextRed, INS_heli_release];
					INS_heli_attatchedList = INS_heli_attatchedList + [_nearest];

					_nearest attachTo [_vehicle,[-1, 0, -8]];
					_nearest engineOn false;
					while {!INS_heli_RELEASED && alive _vehicle && alive _nearest && alive player && (driver _vehicle == player)} do {sleep 1};
					detach _nearest;
					
					INS_heli_ATTACHED = false;
					INS_heli_RELEASED = false;
					
					INS_heli_attatchedList = INS_heli_attatchedList - [_nearest];
					
					if (!alive _vehicle) then {
						_vehicle removeAction _release_id;
					} else { };
					
					waitUntil { (getPos _nearest) select 2 < 10 };
					
					_npos = getPos _nearest;
					_nearest setPos [_npos select 0, _npos select 1, 0];
					
					sleep 1.0;
				};
			};
		};
	};

	sleep 0.5;
};