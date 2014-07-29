// todo use trigger to run loops.


INS_fnc_spawnIEDs = {
	private ["_inc","_pos","_eCount","_wUnits","_wCount","_house","_clear","_gMkr","_houses"];

	for "_i" from (count (call dl_fnc_getAllIEDs)) to 25 do {
		_position = [position player, 300, 400, 0, 1, 20, 0] call BIS_fnc_findSafePos;
		_spawnPos = [_position, 20] call getSideOfRoadPosition;
		diag_log str _spawnPos;
		_ied = [_spawnPos] call generateIED;
	};
};

INS_fnc_despawnIEDs = {

};

ied_types = ["Land_GarbageBags_F", 
			 "Land_WoodPile_F",
			 "Land_GarbagePallet_F", 
			 "Land_GarbageWashingMachine_F", 
			 "Land_JunkPile_F", 
			 "Land_Tyre_F", 
			 "Land_Tyres_F", 
			 "Land_CratesShabby_F", 
			 "Land_Sack_F" , 
			 "Land_Sacks_heap_F"];

generateIED = {
	private ["_ied"];

	_ied = createVehicle [(ied_types call BIS_fnc_selectRandom), (_this select 0), [], 3, "None"];
	//[_ied, "HandleDamage", "(position unit) call iedExplode;"] call dl_fnc_addEventHandlerMP; // add the EV MP
	[_ied, "Disarm IED", disarmIED, [_ied], true, true, "_this distance _target < 2 and _target getVariable 'isActive'"] call dl_fnc_addActionMP;

	_ied setVariable ["code", call generateCode, false];
	_ied setVariable ["isActive", true, true];
	_name = call dl_fnc_getNextIEDID;
	diag_log _name;
	call compile format ["%1 = _ied; publicVariable '%1';", call dl_fnc_getNextIEDID];
	_ied spawn iedLoop;

	_m = createMarker [format ["%1", _name], position _ied];
	_m setMarkerText _name;
    _m setMarkerShape "ICON"; 
    _m setMarkerType "mil_dot";
    _m setMarkerColor "ColorRed";

	_ied
};

generateCode = {
	_code = [];

	for "_i" from 0 to 3 do { _code = _code + [round(random 10)] };

	_code	
};

iedLoop = {
	_ied = _this;

	while { alive _ied and {_ied getVariable "isActive"} } do {
		_nearest = nearestObjects [_ied, ["Man", "Car"], 10];
		
		if ((count _nearest) > 0) then {
			_nearVel = velocity (_nearest select 0);
			_nearSpeed = _nearVel call dl_fnc_velocityToSpeed;
			if (((velocity (_nearest select 0)) call dl_fnc_velocityToSpeed) > 3) then { _ied call iedExplode; };
		};

		sleep 1;
	};
};

disarmIED = {
	private ["_index", "_defuseTime", "_isDefusing", "_ied"];

	_caller = _this select 1;
	_ied = (_this select 3) select 0;
	_code = _ied getVariable "code";
	_index = 0;

	//if !("ToolKit" in (items _caller)) exitWith { hint "need toolkit" };
	_KH = (findDisplay 46) displayAddEventHandler ["KeyDown", "_handled = true; pushedKey = ((_this select 1) - 1); _handled"];

	_defuseTime = 3;
	_isDefusing = true;
	while { _isDefusing } do {
		[format["<t size='5'>%1</t>", _code select _index], 0, 0.2, 0.1, 0] spawn bis_fnc_dynamictext;
		if (!isNil "pushedKey") then {
			if (pushedKey == (_code select _index)) then {
				_index = _index + 1;
				if (_index == (count _code)) then { _isDefusing = false; };
				_defuseTime = 3;
				pushedKey = nil;
			} else {
				_isDefusing = false;
				_ied call iedExplode;
				pushedKey = nil;
			};
		} else {
			if (_defuseTime == 0) then {
				_ied call iedExplode;
				_isDefusing = false;
			};

			_defuseTime = _defuseTime - 0.1;
		};

		sleep 0.1;
	};

	_ied setVariable ["isActive", false, true];
	(findDisplay 46) displayRemoveEventHandler ["KeyDown", _KH];
};

iedExplode = {
	_ied_explosion_types = ["Bo_GBU12_LGB"]; // need more variety
	_type = _ied_explosion_types call BIS_fnc_selectRandom;
	_type createVehicle (position _this);
	deleteVehicle _this;
};


// ---------------------------------------
//	helper functions
// ---------------------------------------

dl_fnc_getAllIEDs = {
	private ["_ied"];
	_iedList = [];

	for "_i" from 0 to 25 do {
		_string = format["ied_%1", _i];
		if (!isNil _string) then {
			_ied = call compile _string;
			if (!isNull _ied and {alive _ied}) then { _iedList = _iedList + [_ied]; };
		};
	};

	_iedList;
};

dl_fnc_getNextIEDID = {
	private ["_unit"];
	_result = "";

	for "_i" from 0 to 25 do {
		_string = format["ied_%1", _i];
		if (isNil _string) exitWith { _result = _string };

		_ied = call compile _string;
		if (isNull _ied) exitWith { _result = _string };
		if (!alive _ied) exitWith { _result = _string };
	};

	_result
};
