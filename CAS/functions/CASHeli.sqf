_object = _this select 0;
_distance = _this select 1;
_loc = getMarkerPos (_this select 2);
_locOrig = getMarkerPos (_this select 3);
_id = _this select 4;

if (waitCAS) exitWith { hintSilent "CAS already enroute, cancel current CAS or wait for CAS execution before next request!" };
waitCAS = true;

_cancelID = player addAction ["Done", "abortCAS = true;"];

_helo = createVehicle ["B_Heli_Attack_01_F", _locOrig, [], 0, "FLY"];
[_helo] execVM "scripts\cas\track.sqf";
_helo setVectorDir [(_loc select 0) - (getPos _helo select 0), (_loc select 1) - (getPos _helo select 1), 0];

_grp = createGroup west;
_pilot = _grp createUnit ["B_Pilot_F", _ranPos, [], 0, "FORM"];
_pilot moveinDriver _helo;
_helo flyInheight 260;

_grp setBehaviour "COMBAT";
_grp setSpeedMode "FULL";
_grp setCombatMode "BLUE";

_helo move _ranPos;

while { true } do {
	if (abortCAS or !(alive _helo)) then {

	}; // abort or heli died

	if ((getPos _helo distance _loc < 500)) exitWith {};	
};

while {!abortCAS && alive _helo} do {
	sleep 1;
	_timeSlept = _timeSlept + 1;

	if (_timeSlept > casPlayerTimeLimit) then {
		player removeAction _cancelID;
		player removeSimpleTask _task;
		abortCAS = true; 
	} else { hint format["%1 seconds left", [casPlayerTimeLimit - _timeSlept]]; };
};

waitCAS = false;
casRequest = false;
deleteMarker "CAS_TARGET";
deleteMarker "CAS_ORIG";
player removeAction _cancelID;