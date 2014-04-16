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

addVehtoArray = {
	_vehicle = (_this select 0);
	_name = (_this select 1);
	_destroyedRespawnDelay = (_this select 2);
	_abandonedRespawnDelay = (_this select 3);
	_abandon = if (_abandonedRespawnDelay == 0) then { false } else { true };
	_init = if (count _this > 4) then { (_this select 4) } else { "" };

	_vehicle setVariable ["RES_NAME", _name];
	_vehicle setVariable ["RES_DESTROY_RESPAWN_DELAY", _destroyedRespawnDelay];
	_vehicle setVariable ["RES_ABANDON_RESPAWN_DELAY", _abandonedRespawnDelay];
	_vehicle setVariable ["RES_ABANDON", _abandon];
	_vehicle setVariable ["RES_INIT", _init];
	_vehicle setVariable ["RES_ORIG_TYPE", typeOf _vehicle];
	_vehicle setVariable ["RES_ORIG_LOC", getPos _vehicle];
	_vehicle setVariable ["RES_ORIG_DIR", getDir _vehicle];

	[[_vehicle, _name, _init], "initParams", true, true] spawn BIS_fnc_MP; // init parameters
	diag_log format["INS_VEH_RESPAWN: adding %1 to respawn array"]
	vehicleArray = vehicleArray + [_vehicle];
	publicVariable "vehicleArray";	
};

if (isServer) then {
	if (isNil "vehicleArray") then { vehicleArray = []; publicVariable "vehicleArray"; };
	if (count _this == 0) then { // called script to loop
		{
			_veh = _x;

			_abandon = _veh getVariable "RES_ABANDON";
			_name = _vehicle getVariable "RES_NAME";
			_destroyedRespawnDelay = _vehicle getVariable "RES_DESTROY_RESPAWN_DELAY";
			_abandonedRespawnDelay = _vehicle getVariable "RES_ABANDON_RESPAWN_DELAY";
			_abandon =_vehicle getVariable "RES_ABANDON";
			_init = _vehicle getVariable "RES_INIT";
			_type = _vehicle getVariable "RES_ORIG_TYPE";
			_origLoc = _vehicle getVariable "RES_ORIG_LOC";
			_origDir = _vehicle getVariable "RES_ORIG_DIR";

			if (_abandon and !_abandonedListen and (count crew _vehicle != 0)) then { _abandonedListen = true; };
			if (_abandon and _abandonedListen and (count crew _vehicle == 0)) then { _abandonedTime = _abandonedTime + 1; };
			if (_abandon and _abandonedListen and (count crew _vehicle != 0)) then { _abandonedTime = 0; };
			if (_abandon and _abandonedTime > _abandonedRespawnDelay) then { _abandoned = true; _respawn = true; };
			if (_abandonedListen and _abandonedTime > (_abandonedRespawnDelay - 60) and _abandonWarn and (count crew _vehicle == 0)) then { [format["<t color='#ff6347'>%1</t> will respawn in %2 seconds", _name, _abandonedRespawnDelay - _abandonedTime], "respawnMessage", true] spawn BIS_fnc_MP; _abandonWarn = false; };
			if (!alive _vehicle) then { _respawn = true; sleep _destroyedRespawnDelay; };

			if (_respawn) then {
				_reason = if (_abandoned) then {"abandoned"} else {"destroyed"};
				[format["respawning %1 vehicle <t color = '#ff6347'>%2</t>", _reason, _name], "respawnMessage", true] spawn BIS_fnc_MP;
				deleteVehicle _vehicle;
				sleep 3;

				_vehicle = _type createVehicle _origLoc;
				[[_vehicle, _name, _init], "initParams", true] spawn BIS_fnc_MP;
			};

			sleep 1;
		} forEach vehicleArray;
	} else { // called script to add vehicle to loop
		_attrs = _this;
		_attrs call addVehtoArray;
	};
};

