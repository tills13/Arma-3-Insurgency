private ["_cache"];

if (isServer) then {
	_area = _this select 0;
	_trigger = (missionNamespace getVariable format["%1_trigger", (_area select 0)]);

	// args: [trigger, [spawned infantry, unspawned infantry, vehicles, static]]
	INS_ai_fnc_cacheUnits = {
		_trigger = _this select 0;
		_area = _this select 1;
		_cache = _this select 2;

		_unspawnedinfantry = _cache select 0;
		_spawnedinfantry = _cache select 1;
		_lightvehicles = _cache select 2;
		_statics = _cache select 3;

		_infcache = _spawnedinfantry call INS_fnc_cacheInfantry;
		_lvcache = _lightvehicles call INS_fnc_cacheLightVehicles;
		_spcache = _statics call INS_fnc_cacheStaticPlacements;

		_trigger setVariable [format["%1_cache", (_area select 0)], true];
		_trigger setVariable [format["%1_cache_in", (_area select 0)], (_infcache + _unspawnedinfantry)];
		_trigger setVariable [format["%1_cache_lv", (_area select 0)], _lvcache];
		_trigger setVariable [format["%1_cache_sp", (_area select 0)], _spcache];
	};

	// args: [trigger, _area]
	INS_ai_fnc_spawnUnits = {
		private ["_trigger", "_area"];

		_trigger = _this select 0;
		_area = _this select 1;

		_areacache = _trigger getVariable format["%1_cache", (_area select 0)];
		_areaClassName = _area select 0;
		_areaPos = _area select 2;
		_areaRad = _area select 3;

		_ipositions = [];
		_lightvehicles = [];
		_statics = [];
		if (!isNil "_areacache") then {  // load from cache
			_ipositions = _trigger getVariable format["%1_cache_in", (_area select 0)];
			_lightvehicles = _trigger getVariable format["%1_cache_lv", (_area select 0)];
			_statics = _trigger getVariable format["%1_cache_sp", (_area select 0)];

			_lightvehicles = [_lightvehicles] call INS_fnc_spawnLightVehiclesCached;
			_statics = [_statics] call INS_fnc_spawnStaticUnitsCached;
		} else {
			_ipositions = [_areaClassName, _areaPos, _areaRad] call INS_fnc_genInfantryPositions;	
			_lightvehicles = [_areaClassName, _areaPos, _areaRad] call INS_fnc_spawnLightVehicles;
			_statics = [_areaClassName, _areaPos, _areaRad] call INS_fnc_spawnStaticUnits;
		};
		
		[_ipositions, [], _lightvehicles, _statics]
	};

	waitUntil { triggerActivated _trigger };
	_timeStart = time;

	if (debugMode == 1) then { diag_log format["%1 zone activated", _area select 0]; };
	_cache = [_trigger, _area] call INS_ai_fnc_spawnUnits;
	_infantry = _cache select 0;

	while { triggerActivated _trigger } do {
		private ["_x", "_pos", "_size"];
		_playableUnits = playableUnits;

		_index = 0;

		{
			//diag_log _x;
			_group = _x;
			_size = _group select 0;
			_pos = _group select 1;

			{
				private ["_x"];
				// todo: put into one function
				if (position _x distance _pos < 500 or (([_x, _pos] call dl_fnc_canSee) and position _x distance _pos < 1000)) then {
					_patrol = [_size, _pos] call INS_fnc_spawnGroup;
					_mpatrols = _cache select 1;
					_mpatrols = _mpatrols + [_patrol];
					_cache set [1, _mpatrols];

					_infantry set [_index, 0];
					_infantry = _infantry - [0];
					_cache set [0, _infantry];
				};
			} forEach _playableUnits;

			sleep 0.1;
			_index = _index + 1;
		} forEach _infantry;

		if (time - _timeStart > 60) then {}; // one minute
		if (time - _timeStart > 300) then {}; // five minutes
		if (time - _timeStart > 600) then {}; // ten minutes 	

		if (not triggerActivated _trigger) then { sleep 10 } else { sleep 1 }; // give chance to leave/re-enter zone
	};

	if (debugMode == 1) then { diag_log format["%1 zone deactivated (%2)", _area select 0, time - _timeStart]; };

	[_trigger, _area, _cache] call INS_ai_fnc_cacheUnits;
};