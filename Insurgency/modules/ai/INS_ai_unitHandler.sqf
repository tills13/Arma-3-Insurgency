if (!isServer) exitWith {}; // server handles all spawning

_city = _this select 0;
_trigger = (missionNamespace getVariable format["%1_trigger", (_city select 0)]);
if (!isNil "_trigger") exitWith {};

// args: [trigger, [house, area, vehicles, static]]
INS_ai_fnc_cacheUnits = {
	_trigger = _this select 0;

	_cache = _this select 1;
	_hpatrols = _cache select 1;
	_patrols = _cache select 2;
	_lightvehicles = _cache select 3;
	_static = _cache select 4;

	_hpcache = _hpatrols call INS_fn_cacheHousePatrols;
	_apcache = _patrols call INS_fn_cacheAreaPatrols;
	_lvcache = _lightvehicles call INS_fn_cacheLightVehicles;
	_spcache = _statics call INS_fn_cacheStaticPlacements;

	_trigger setVariable [format["%1_cache", _cityClassName], true];
	_trigger setVariable [format["%1_cache_hp", _cityClassName], _hpcache];
	_trigger setVariable [format["%1_cache_ap", _cityClassName], _apcache];
	_trigger setVariable [format["%1_cache_lv", _cityClassName], _lvcache];
	_trigger setVariable [format["%1_cache_sp", _cityClassName], _spcache];
};

// args: [trigger, [house, area, vehicles, static]]
INS_ai_fnc_spawnUnits = {
	_areacache = _trigger getVariable format["%1_cache", _cityClassName];
	_cityName = _this select 0;
	_cityPos = _this select 1;
	_cityRad = _this select 2;

	if (!isNil "_areacache") then {  // load from cache
		_hpatrols = _trigger getVariable format["%1_cache_hp", _cityClassName];
		_patrols = _trigger getVariable format["%1_cache_ap", _cityClassName];
		_lightvehicles = _trigger getVariable format["%1_cache_lv", _cityClassName];
		_statics = _trigger getVariable format["%1_cache_sp", _cityClassName];

		 
	} else {
		_hpatrols = [_cityName, _cityPos, _cityRad] call INS_fn_spawnHousePatrols;
		_patrols = [_cityName, _cityPos, _cityRad] call INS_fn_spawnAreaPatrols;
		_lightvehicles = [_cityName, _cityPos, _cityRad] call INS_fn_spawnLightVehicles
		_statics = [_cityName, _cityPos, _cityRad] call INS_fn_spawnStaticUnits

		exitWith { [_hpatrols, _patrols, _lightvehicles, _statics] };
	};
};

waitUntil { triggerActivated _trigger };
_timeStart = time;

_cache = [(_city select 0), (_city select 1), (_city select 2)] call INS_ai_fnc_spawnUnits;

while { triggerActivated _trigger } do {
	if (_timeStart - time > 60) then { // one minute };
	if (_timeStart - time > 300) then { // five minutes };	
	if (_timeStart - time > 600) then { // ten minutes };	

	sleep 1;
};

[_trigger, _cache] call INS_ai_fnc_cacheUnits;

/* we should only load if the unit is either
 * visible or within 200 meters. 
 *
 *
 */