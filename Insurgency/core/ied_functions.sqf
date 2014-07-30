// todo use trigger to run loops.

INS_num_ieds = 25;
INS_fnc_spawnIEDs = {
	private ["_spawnPos","_position"];

	for "_i" from 0 to (INS_num_ieds - (count (call dl_fnc_getAllIEDs))) do {
		_position = [position player, 300, 400, 0, 1, 20, 0] call BIS_fnc_findSafePos;
		_spawnPos = [_position, 20] call getSideOfRoadPosition;
		_spawnPos call INS_fnc_generateIED;
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

INS_fnc_generateIED = {
	private ["_ied"];

	_ied = createVehicle [(ied_types call BIS_fnc_selectRandom), _this, [], 3, "NONE"];
	
	[_ied, "HitPart", "(position _ied) call iedExplode;"] call dl_fnc_addEventHandlerMP; // add the EV MP DOESN'T WORK YET
	//_ied addEventHandler ["HitPart", { player sideChat "HitPart"; }]; 
	[_ied, "Disarm IED", disarmIED, [_ied], true, true, "_this distance _target < 2 and _target getVariable 'isActive'"] call dl_fnc_addActionMP;

	_ied setVariable ["code", call generateCode, false];
	_ied setVariable ["isActive", true, true];

	
	call compile format ["%1 = _ied;", call dl_fnc_getNextIEDID];
	diag_log str _ied;
	diag_log (call dl_fnc_getNextIEDID);
	//_ied spawn iedLoop;

	_m = createMarker [format ["%1", random 10000], position _ied];
 	_m setMarkerText str (random 10000);
    _m setMarkerShape "ICON"; 
    _m setMarkerType "mil_dot";
    _m setMarkerColor "ColorRed";
};

generateCode = {
	_code = [];

	for "_i" from 0 to 3 do { _code = _code + [1 max round(random 9)] };

	_code	
};

iedLoop = {
	_ied = _this;

	while { !isNull _ied and {_ied getVariable "isActive"} } do {
		_nearest = nearestObjects [_ied, ["Man", "Car"], 10];
		
		if ((count _nearest) > 0) then {
			{
				_vel = velocity (_x);
				_speed = _vel call dl_fnc_velocityToSpeed;

				if (_speed > 3) then { _ied call iedExplode; };
			} forEach _nearest;
		};

		sleep 1;
	};
};

disarmIED = {
	private ["_index", "_defuseTime", "_isDefusing"];

	_caller = _this select 1;
	ied = (_this select 3) select 0;
	code = ied getVariable "code";
	index = 0;

	//if !("ToolKit" in (items _caller)) exitWith { hint "need toolkit" };
	_KH = (findDisplay 46) displayAddEventHandler ["KeyDown", "_handled = true; pushedKey = ((_this select 1) - 1); _handled"];
	0 = [((count code) * 3.4), _KH] spawn { sleep (_this select 0); (findDisplay 46) displayRemoveEventHandler ["KeyDown", (_this select 1)]; }; // just incase something goes wrong we give control back to the user after the max time

	onEachFrame {
		if (!isNil "pushedKey") then {
			if (pushedKey == (code select index)) then {
				index = index + 1;
				//_defuseTime = 3.4;
				//_nextIndex = true;
			} else { ied call iedExplode };

			pushedKey = nil;
		}; 
	};
	/*_defuseTime = 3; // seconds
	_nextIndex = true;
	while { !isNull _ied and {_index != (count _code)} } do {
		// should give a nice "scramble" effect
		if (_nextIndex) then { _nextIndex = false; for "_i" from 0 to 6 do { [format["<t size='3'>%1</t>", round random 10], 0, 0.2, 0.1, 0] spawn bis_fnc_dynamictext; sleep 0.1; }; }
		else { [format["<t color='#ff6347' size='3'>%1</t>", _code select _index], 0, 0.2, 0.1, 0] spawn bis_fnc_dynamictext; };

		if (!isNil "pushedKey") then {
			if (pushedKey == (_code select _index)) then {
				_index = _index + 1;
				_defuseTime = 3.4;
				_nextIndex = true;
			} else { _ied call iedExplode };

			pushedKey = nil;
		};

		_defuseTime = _defuseTime - 0.1;
		if (_defuseTime == 0) exitWith { _ied call iedExplode };

		sleep 0.1;
	};*/

	_ied setVariable ["isActive", false, true];
	if (!isNull _ied) then { ["<t color='#80FF80' size='3'>success</t>", 0, 0.2, 0.1, 0] spawn bis_fnc_dynamictext; };
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

	for "_i" from 0 to INS_num_ieds do {
		_string = format["ied_%1", _i];
		if (!isNil _string) then {
			_ied = call compile _string;
			if (!isNull _ied and {_ied getVariable "isActive"}) then { _iedList = _iedList + [_ied]; };
		};
	};

	_iedList;
};

dl_fnc_getNextIEDID = {
	private ["_ied"];
	_result = "";

	for "_i" from 0 to INS_num_ieds do {
		_string = format["ied_%1", _i];
		if (isNil _string) exitWith { _result = _string };

		_ied = call compile _string;
		if (isNull _ied) exitWith { _result = _string };
		if (!(_ied getVariable "isActive")) exitWith { _result = _string };
	};

	_result
};
