// todo: addAction needs to be global in MP
generateIED = { // call on server only
	_position = _this select 0;
	_ied = createVehicle ["Land_GarbageBags_F", _position, [], 0, "None"];
	_ied addAction ["Disarm IED", disarmIED, nil, 10, true, false, "", "_this hasItem 'ToolKit' and _this distance _target < 5"];
	
	_beep = createSoundSource ["Sound_Alarm", _position, [], 0];
	[_ied, _beep] call iedLoop;
};

generateCode = {
	_code = [];

	for "_i" from 0 to 3 do { _code = _code + [random 10] };

	_code	
};

disarmIED = {
	_caller = _this select 1;
	_code = call generateCode;
	_index = 0;

	// need a key listener

	for "_i" from 0 to (count _code - 1) do {
		titleText (str _code select _i);

		waitUntil { !isNil "pushedKey" };

		if (pushedKey != _code select _index) { _index = _index + 1 } else 
		pushedKey = nil;
	};
};

initializeTrigger = {
	_ied = _this select 0;
	_range = _this select 1;
};

iedLoop = {
	[_this] spawn {
		_ied = _this select 0;
		_alarm = _this select 1;

		while { alive _this } do {
			_nearest = nearestObject ["Man", "Car"];
			if (_nearest distance _ied < 3) then {
				if (velocity _nearest > 3) then {
					// blow
				};
			};

			sleep 1;
		};

		deleteVehicle _alarm;
	};
};

if (isServer) then {

};