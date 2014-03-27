_object = _this select 0;
_distance = _this select 1;
_casType = _this select 2;
_loc = getMarkerPos (_this select 3);
_locOrig = getMarkerPos (_this select 4);
_id = _this select 5;

if (waitCAS) exitWith { hintSilent "CAS already enroute, cancel current CAS or wait for CAS execution before next request!" };
waitCAS = true;

_canceliD = player addAction ["Done", "abortCAS = true;"];

_dis = _loc distance _locOrig;
_ranPos = _locOrig;

_buzz = createVehicle ["B_Plane_CAS_01_F", _ranPos, [], 0, "FLY"];
[_buzz] execVM "scripts\cas\track.sqf";
_buzz setVectorDir [(_loc select 0) - (getPos _buzz select 0), (_loc select 1) - (getPos _buzz select 1), 0];

sleep 0.2;

_dir = getDir _buzz;
_buzz setVelocity [sin(_dir) * 200, cos(_dir) * 200, 5];

_originalPos = getPos player;
player moveinDriver _buzz;

_timeSlept = 0;
while {!abortCAS && alive _buzz} do {
	sleep 1;
	_timeSlept = _timeSlept + 1;

	if (_timeSlept > casPlayerTimeLimit) then {
		player removeAction _canceliD;
		abortCAS = true; 
	} else { hint format["%1 seconds left", [casPlayerTimeLimit - _timeSlept]]; };
};

player removeAction _canceliD;
player setPos _originalPos;
waitCAS = false;
casRequest = false;

if (alive _buzz) then {
	_grp = createGroup west;
	_pilot = _grp createUnit ["B_Pilot_F", _ranPos, [], 0, "FORM"];
	_pilot moveinDriver _buzz;
	_buzz flyInheight 260;

	_grp setBehaviour "STEALTH";
	_grp setSpeedMode "FULL";
	_grp setCombatMode "BLUE";

	_buzz move _ranPos;

	_countDown = [] spawn {
		timeUntilNextCAS = casPlayerTimeout;
		while { timeUntilNextCAS > 0 } do {
			sleep 1;
			timeUntilNextCAS = timeUntilNextCAS - 1; 
		};
	};

	waitUntil{ _buzz distance _object >= 4000 || !alive _buzz };
};

deleteVehicle vehicle _buzz;
deleteVehicle _buzz;
deleteMarker "CAS_TARGET";
deleteMarker "CAS_ORIG";