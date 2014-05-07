// todo use trigger to run loops.

if (isServer) then {
	_area = _this;
	_trigger = (missionNamespace getVariable format["%1_trigger", (_area select 0)]);

	generateIEDs = {
		private ["_ied", "_ieds"];
		_area = _this;
		_areaPos = _area select 2;
		_areaRad = _area select 3;

		_ieds = [];
		for "_i" from 0 to random 10 do {
			_pos = [_areaPos, _areaRad] call getSideOfRoadPosition;
			_ied = [_pos] call generateIED;
			_ieds = _ieds + [_ied];
		};

		_ieds
	};

	
	generateIED = { // call on server only
		_ied_types = ["Land_GarbageBags_F", "Land_WoodPile_F", "Land_GarbagePallet_F", "Land_GarbageWashingMachine_F", "Land_JunkPile_F", "Land_Tyre_F", "Land_Tyres_F", "Land_CratesShabby_F", "Land_Sack_F" , "Land_Sacks_heap_F"];
		_position = _this select 0;
		_type = _ied_types call BIS_fnc_selectRandom;

		_ied = createVehicle [_type, _position, [], 3, "None"];
		[_ied, "HandleDamage", "(position unit) call iedExplode;"] call dl_fnc_addEventHandlerMP; // add the EV MP
		[_ied, "Disarm IED", disarmIED, [_ied], true, true, "_this distance _target < 2 and _target getVariable 'isActive'"] call dl_fnc_addActionMP;

		_ied setVariable ["code", call generateCode, false];
		_ied setVariable ["isActive", true, true];
		_ied call iedLoop;

		_ied
	};

	generateCode = {
		_code = [];

		for "_i" from 0 to 3 do { _code = _code + [round(random 10)] };

		_code	
	};

	iedLoop = {
		_this spawn {
			_ied = _this;

			while { alive _ied and (_ied getVariable "isActive") } do {
				_nearest = nearestObjects [_ied, ["Man","Car"], 10];
				
				if ((count _nearest) > 0) then {
					_nearVel = velocity (_nearest select 0);
					_nearSpeed = _nearVel call dl_fnc_velocityToSpeed;
					if (((velocity (_nearest select 0)) call dl_fnc_velocityToSpeed) > 3) then { _ied call iedExplode; };
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
		_KH = (findDisplay 46) displayAddEventHandler ["KeyDown", "_handled = true; pushedKey = ((_this select 1) - 1); _handled"];

		_defuseTime = 3;
		_isDefusing = true;
		while { _isDefusing } do {
			[format["<t size='5'>%1</t>", _code select _index], 0, 0.2, 0.1, 0] spawn bis_fnc_dynamictext;
			if (!isNil "pushedKey") then {
				if (pushedKey == (_code select _index)) then {
					_index = _index + 1;
					if (_index == 4) then { _isDefusing = false; };
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

	waitUntil { triggerActivated _trigger };
	//_ieds = _area call generateIEDs; // spawn 'em

	waitUntil { !triggerActivated _trigger };
	//{ deleteVehicle _x } foreach _ieds; // delete 'em
};