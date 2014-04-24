if (!isServer) exitWith {}; // server handles all spawning

_area = _this;
_trigger = (missionNamespace getVariable format["%1_trigger", (_area select 0)]);

// args: [trigger, [house, area, vehicles, static]]
INS_ai_fnc_cacheUnits = {
	_trigger = _this select 0;
	_area = _this select 1;
	_cache = _this select 2;

	_hpatrols = _cache select 0;
	_patrols = _cache select 1;
	_lightvehicles = _cache select 2;
	_statics = _cache select 3;

	_hpcache = _hpatrols call INS_fn_cacheHousePatrols;
	_apcache = _patrols call INS_fn_cacheAreaPatrols;
	_lvcache = _lightvehicles call INS_fn_cacheLightVehicles;
	_spcache = _statics call INS_fn_cacheStaticPlacements;

	diag_log format["%1, %2, %3, %4", _hpatrols, _patrols, _lightvehicles, _statics];
	diag_log format["%1, %2, %3, %4", _hpcache, _apcache, _lvcache, _spcache];

	_trigger setVariable [format["%1_cache", (_area select 0)], true];
	_trigger setVariable [format["%1_cache_hp", (_area select 0)], _hpcache];
	_trigger setVariable [format["%1_cache_ap", (_area select 0)], _apcache];
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

	_hpatrols = [];
	_patrols = [];
	_lightvehicles = [];
	_statics = [];
	if (!isNil "_areacache") then {  // load from cache
		_hpatrols = _trigger getVariable format["%1_cache_hp", (_area select 0)];
		_patrols = _trigger getVariable format["%1_cache_ap", (_area select 0)];
		_lightvehicles = _trigger getVariable format["%1_cache_lv", (_area select 0)];
		_statics = _trigger getVariable format["%1_cache_sp", (_area select 0)];

		_hpatrols = [_hpatrols] call INS_fn_spawnHousePatrolsCached;
		_patrols = [_patrols] call INS_fn_spawnAreaPatrolsCached;
		_lightvehicles = [_lightvehicles] call INS_fn_spawnLightVehiclesCached;
		_statics = [_statics] call INS_fn_spawnStaticUnitsCached;
	} else {
		_hpatrols = [_areaClassName, _areaPos, _areaRad] call INS_fn_spawnHousePatrols;
		_patrols = [_areaClassName, _areaPos, _areaRad] call INS_fn_spawnAreaPatrols;
		_lightvehicles = [_areaClassName, _areaPos, _areaRad] call INS_fn_spawnLightVehicles;
		_statics = [_areaClassName, _areaPos, _areaRad] call INS_fn_spawnStaticUnits;
	};

	[_hpatrols, _patrols, _lightvehicles, _statics]
};

waitUntil { triggerActivated _trigger };
_timeStart = time;

diag_log format["%1 zone activated", _area select 0];
_cache = [_trigger, _area] call INS_ai_fnc_spawnUnits;

while { triggerActivated _trigger } do {
	diag_log format["%1 zone activated (%2)", _area select 0, time - _timeStart];
	if (time - _timeStart > 60) then {}; // one minute
	if (time - _timeStart > 300) then {}; // five minutes
	if (time - _timeStart > 600) then {}; // ten minutes 	

	sleep 10;
};

diag_log format["%1 zone deactivated (%2)", _area select 0, time - _timeStart];

[_trigger, _area, _cache] call INS_ai_fnc_cacheUnits;

/* we should only load if the unit is either
 * visible or within 200 meters. 
 *
 *
 */