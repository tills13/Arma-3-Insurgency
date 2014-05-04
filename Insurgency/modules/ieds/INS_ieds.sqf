// todo use area trigger to run loops.

generateIEDs = {
	_area = _this;
	_areaPos = _area select 2;
	_areaRad = _area select 3;
	_alreadyGenerated = missionNamespace getVariable [format["%1_ieds", _area select 0], false];

	if (!_alreadyGenerated) then {
		for "_i" from 0 to 30 do {
			_pos = [_areaPos, _areaRad] call getSideOfRoadPosition;
			[_pos] call generateIED;

			if (debugMode == 1) then {
		        _m = createMarker [format ["box%1", random 1000], _pos];
		        _m setMarkerShape "ICON"; 
		        _m setMarkerType "mil_dot";
		        _m setMarkerColor "ColorRed";
			};
		};

		missionNamespace setVariable [format["%1_ieds", _area select 0], true];
	};
};

ied_types = ["Land_GarbageBags_F", "Land_WoodPile_F", "Land_GarbagePallet_F", "Land_GarbageWashingMachine_F", "Land_JunkPile_F", "Land_Tyre_F", "Land_Tyres_F", "Land_CratesShabby_F", "Land_Sack_F" , "Land_Sacks_heap_F"];
generateIED = { // call on server only
	_position = _this select 0;
	_type = ied_types call BIS_fnc_selectRandom;

	_ied = createVehicle [_type, _position, [], 3, "None"];
	[_ied, "Disarm IED", disarmIED, [_ied], true, true, "true"] call addActionMPHelper; // add the action MP
	[_ied, "HandleDamage", "(position unit) call iedExplode;"] call addEventHandlerMPHelper; // add the EV MP

	_ied setVariable ["code", call generateCode, false];
	_ied call iedLoop;
};

generateCode = {
	_code = [];

	for "_i" from 0 to 3 do { _code = _code + [round(random 10)] };

	_code	
};

iedLoop = {
	_this spawn {
		_ied = _this;

		while { alive _ied } do {
			_nearest = nearestObjects [_ied, ["Man","Car"], 5];
			
			if ((count _nearest) > 0) then {
				_nearVel = velocity (_nearest select 0);
				_nearSpeed = _nearVel call dl_fnc_velocityToSpeed;
				if (((velocity (_nearest select 0)) call dl_fnc_velocityToSpeed) > 3) then {
					(position _ied) call iedExplode;
					deleteVehicle _ied;
				};
			};

			sleep 1;
		};
	};
};

disarmIED = {
	private ["_index", "_defuseTime", "_isDefusing"];

	_caller = _this select 1;
	_ied = (_this select 3) select 0;
	_code = _ied getVariable "code";
	_index = 0;

	//if !("ToolKit" in (items _caller)) exitWith { hint "need toolkit" };
	_KH = (findDisplay 46) displayAddEventHandler ["KeyDown", "pushedKey = ((_this select 1) - 1);"];

	_defuseTime = 3;
	_isDefusing = true;
	while { _isDefusing } do {
		hint str (_code select _index);
		if (!isNil "pushedKey") then {
			if (pushedKey == (_code select _index)) then {
				_index = _index + 1;
				if (_index == 4) then { _isDefusing = false; };
				_defuseTime = 3;
				pushedKey = nil;
			} else {
				_isDefusing = false;
				(position _ied) call iedExplode;
				deleteVehicle _ied;
				// delete
				pushedKey = nil;
			};
		} else {
			if (_defuseTime == 0) then {
				(position _ied) call iedExplode;
				deleteVehicle _ied;
				_isDefusing = false;
			};

			_defuseTime = _defuseTime - 1;
		};

		diag_log format ["%1 %2", _defuseTime, _code select _index];
		sleep 1;
	};
};

ied_explosion_types = ["Bo_GBU12_LGB"];
iedExplode = {
	_type = ied_explosion_types call BIS_fnc_selectRandom;
	_type createVehicle _this;
};

if (isServer) then {
	_area = _this;
	_area call generateIEDs;
};