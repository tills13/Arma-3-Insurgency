initParams = {
	_vehicle = (_this select 0);
	_isHQ = (_this select 1);
	_cas = (_this select 2);

	if (_isHQ) then { _vehicle addAction["Virtual Ammobox", "VAS\open.sqf"]; };
	if (_cas) then { [_vehicle, 500] execVM "cas\functions\addAction.sqf"; };
};

if (isServer) then {
	_vehicle = (_this select 0);
	_name = (_this select 1);
	_isHQ = (_this select 2);
	_abandon = (_this select 3);
	_cas = if (count _this > 4) then { (_this select 4) } else { false };

	_origLoc = getPos _vehicle;
	_type = typeOf _vehicle;

	_vehicle setVehicleVarName _name;
	_vehicle call compile format ["%1 = _this; publicVariable ""%1""", _name];
	[[_vehicle, _isHQ, _cas], "initParams", true, false] spawn BIS_fnc_MP;

	_abandonedListen = false;
	_abandonedTime = 0;
	_respawn = false;
	_abandoned = false;

	while { true } do {
		if (_abandon and !_abandonedListen and (count crew _vehicle != 0)) then { _abandonedListen = true; };
		if (_abandon and _abandonedListen and (count crew _vehicle == 0)) then { _abandonedTime = _abandonedTime + 1; };
		if (_abandon and _abandonedListen and (count crew _vehicle != 0)) then { _abandonedTime = 0; };
		if (_abandon and _abandonedTime > 300) then { _abandoned = true; _respawn = true; };
		if (!alive _vehicle) then { _respawn = true; sleep 60; };

		if (_respawn) then {
			deleteVehicle _vehicle; 
			sleep 2;

			_reason = if (_abandoned) then {"abandoned"} else {"destroyed"};
			hint parseText format["respawning %1 vehicle <t color='#eaeaea'>%2</t>", _reason, _name];

			_vehicle = _type createVehicle _origLoc;
			_vehicle call compile format ["%1 = _this; publicVariable ""%1""", _name];
			_vehicle setVehicleVarName _name;
			[[_vehicle, _isHQ, _cas], "initParams", true, false] spawn BIS_fnc_MP;

			_abandonedListen = false;
			_abandonedTime = 0;
			_respawn = false;
			_abandoned = false;
		};

		sleep 1.0;
	};
};