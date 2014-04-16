//[vehicle, name, destroyedRespawnTime, abandonedRespawnTime, init] execVM "respawn.sqf";

respawnMessage = { 
	hint parseText _this;
};

initParams = { // should be executed on every client
	_vehicle = (_this select 0);
	_name = (_this select 1);
	_init = (_this select 2);

	if (debugMode == 1) then { diag_log format["initializing %1: %2", _name, _init]; };
	_vehicle call compile format ["%1 = _this; publicVariable ""%1""; " + _init, _name];
	_vehicle setVehicleVarName _name;
};

if (isServer) then {
	_vehicle = (_this select 0);
	_name = (_this select 1);
	_destroyedRespawnDelay = (_this select 2);
	_abandonedRespawnDelay = (_this select 3);
	_abandon = if (_abandonedRespawnDelay == 0) then { false } else { true };
	_init = if (count _this > 4) then { (_this select 4) } else { "" };

	_origLoc = getPosASL _vehicle;
	_type = typeOf _vehicle;
	[[_vehicle, _name, _init], "initParams", true, true] spawn BIS_fnc_MP; // init parameters

	while { true } do {
		_abandonedListen = false;
		_abandonedTime = 0;
		_abandonWarn = true;
		_respawn = false;
		_abandoned = false;

		while { !_respawn } do {
			if (_abandon and !_abandonedListen and (count crew _vehicle != 0)) then { _abandonedListen = true; };
			if (_abandon and _abandonedListen and (count crew _vehicle == 0)) then { _abandonedTime = _abandonedTime + 1; };
			if (_abandon and _abandonedListen and (count crew _vehicle != 0)) then { _abandonedTime = 0; };
			if (_abandon and _abandonedTime > _abandonedRespawnDelay) then { _abandoned = true; _respawn = true; };
			if (_abandonedListen and _abandonedTime > (_abandonedRespawnDelay - 60) and _abandonWarn and (count crew _vehicle == 0)) then { [format["<t color='#ff6347'>%1</t> will respawn in %2 seconds", _name, _abandonedRespawnDelay - _abandonedTime], "respawnMessage", true] spawn BIS_fnc_MP; _abandonWarn = false; };
			if (!alive _vehicle) then { _respawn = true; sleep _destroyedRespawnDelay; };

			if (_respawn) then {
				_reason = if (_abandoned) then {"abandoned"} else {"destroyed"};
				[format["respawning %1 vehicle <t color='#ff6347'>%2</t>", _reason, _name], "respawnMessage", true] spawn BIS_fnc_MP;
				deleteVehicle _vehicle;
				sleep 3;

				_vehicle = _type createVehicle _origLoc;
				[[_vehicle, _name, _init], "initParams", true, false] spawn BIS_fnc_MP;
			};

			sleep 1.0;
		};
	};
	
};