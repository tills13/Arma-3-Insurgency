private ["_group"];

if (isServer) then {
	_area = _this;
	_trigger = (missionNamespace getVariable format["%1_trigger", (_area select 0)]);

	// args: [trigger, [house, area, vehicles, static]]
	INS_ai_fnc_cacheUnits = {
		_trigger = _this select 0;
		_area = _this select 1;
		_cache = _this select 2;

		_patrols = _cache select 0;
		_lightvehicles = _cache select 1;
		_statics = _cache select 2;

		_infcache = _patrols call INS_fn_cacheInfantry;
		//_hpcache = _hpatrols call INS_fn_cacheHousePatrols;
		//_apcache = _patrols call INS_fn_cacheAreaPatrols;
		_lvcache = _lightvehicles call INS_fn_cacheLightVehicles;
		_spcache = _statics call INS_fn_cacheStaticPlacements;

		_trigger setVariable [format["%1_cache", (_area select 0)], true];
		_trigger setVariable [format["%1_cache_p", (_area select 0)], _patrols];
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

		_patrols = [];
		_lightvehicles = [];
		_statics = [];
		if (!isNil "_areacache") then {  // load from cache
			_patrols = _trigger getVariable format["%1_cache_p", (_area select 0)];
			_lightvehicles = _trigger getVariable format["%1_cache_lv", (_area select 0)];
			_statics = _trigger getVariable format["%1_cache_sp", (_area select 0)];

			_patrols = [_patrols] call INS_fn_spawnInfantryCached;
			_lightvehicles = [_lightvehicles] call INS_fn_spawnLightVehiclesCached;
			_statics = [_statics] call INS_fn_spawnStaticUnitsCached;
		} else {
			_hppositions = [_areaClassName, _areaPos, _areaRad] call INS_fn_genHousePatrols;
			_appositions = [_areaClassName, _areaPos, _areaRad] call INS_fn_genAreaPatrols;
			_lightvehicles = [_areaClassName, _areaPos, _areaRad] call INS_fn_spawnLightVehicles;
			_statics = [_areaClassName, _areaPos, _areaRad] call INS_fn_spawnStaticUnits;
		};

		[_hppositions + _appositions, _lightvehicles, _statics]
	};

	waitUntil { triggerActivated _trigger };
	_timeStart = time;

	diag_log format["%1 zone activated", _area select 0];
	_cache = [_trigger, _area] call INS_ai_fnc_spawnUnits;
	_cache = [[], [], []];

	while { triggerActivated _trigger } do {
		_playableUnits = playableUnits;

		_index = 0;

		{	
			_size = _x select 0;
			_pos = _x select 1;

			{
				if (getPos _x distance _pos < 200) then {
					_patrol = [_size, _pos] call INS_fn_spawnGroup;
					_mpatrols = _cache select 0;
					_mpatrols = _mpatrols + [_patrol];
					_cache set [0, _mpatrols];

					_unspawned set [_index, 0];
					_unspawned = _unspawned - [0];
				};
			} forEach _playableUnits;

			_index = _index + 1;
		} forEach _unspawned;

		diag_log str _cache;
		if (time - _timeStart > 60) then {}; // one minute
		if (time - _timeStart > 300) then {}; // five minutes
		if (time - _timeStart > 600) then {}; // ten minutes 	

		sleep 1;
	};

	diag_log format["%1 zone deactivated (%2)", _area select 0, time - _timeStart];

	//[_trigger, _area, _cache] call INS_ai_fnc_cacheUnits;

	/* we should only load if the unit is either
	 * visible or within 200 meters. 
	 *
	 *
	 */
};