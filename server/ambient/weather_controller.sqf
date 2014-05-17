//------------------------------------------------------
// Usage: [overcast value, [fog value, fog decay, fog base], rain value, rainbow, [wind strength, wind gusts, wave value]]
//------------------------------------------------------

_overCast = _this select 0;

_fogArgs = _this select 1;
_fog = _fogArgs select 0;
_fogDecay = _fogArgs select 1;
_fogBase = _fogArgs select 2;

_rainIntensity = _this select 2;
_rainbow = _this select 3;

_windArgs = _this select 4;
_windStr = _windArgs select 0;
_windGus = _windArgs select 1;
_waves = _windArgs select 2;


0 setFog _fogArgs;
0 setWindStr  _windStr;
0 setWindForce _windGus;
0 setWaves _waves;
0 setOvercast _overCast;
0 setRain _rainIntensity;
0 setRainbow _rainbow;

simulWeatherSync;
skiptime 1;

_wasRaining = (_overcast > 0.7 && _rainIntensity > 0);

while { True } do {
	//_timeInFuture = weatherChangeRate + random weatherChangeRate;
	//sleep (_timeInFuture / 2);	
	_overCast = random 1;

	if (_overCast > 0.3) then {
		if (random 1 > 0.70) {
			_fog = random 1;
			_fogDecay = random 0.5;
			_fogBase = random 50;
		} else {
			_fog = 0;
			_fogDecay = random 0.5;
			_fogBase = random 50;
		};

		_windStr = 0.2 + random 1;
		_windGus = 0.1 + random 1;

		if (_overCast > 0.7 && random 1 > 0.5) then { _rainIntesity = random 1; _wasRaining = true; };
		_rainbow = 0;
	} else {
		_rainIntesity = 0;
		if (humidity > 0.5 && (random 1 > 0.5)) then {
			_rainbow = 1;
			_fog = 0.2;
			_wasRaining = false;
		} else { _fog = 0; };

		_fogDecay = 0.01;
		_fogBase = 0;
		_windStr = random 0.5;
		_windGus = random 0.5;
	};

	_timeInFuture setWindStr  _windStr;
	_timeInFuture setWindForce _windGus;
	_timeInFuture setWaves _windStr;
	_timeInFuture setOvercast _overCast;
	_timeInFuture setFog _fog;
	_timeInFuture setRain _rainIntensity;
	_timeInFuture setRainbow _rainbow;
};