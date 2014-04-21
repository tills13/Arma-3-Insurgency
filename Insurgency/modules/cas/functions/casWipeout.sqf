if (INS_CAS_waitCAS) exitWith { hintSilent "CAS already enroute, cancel current CAS or wait for CAS execution before next request!" };
INS_CAS_waitCAS = true; publicVariable "INS_CAS_waitCAS";

_targetLoc = getMarkerPos "CAS_TARGET";
_originLoc = getMarkerPos "CAS_ORIG";

INS_cancel_AID = player addAction ["Done CAS", "INS_CAS_abortCAS = true;"];

_plane = ["B_Plane_CAS_01_F", _originLoc, _targetLoc] call INS_CAS_spawnAircraft;

(driver _plane) doMove _targetLoc;
_wp = group _plane addWaypoint [_targetLoc, 0];
_wp setWaypointType "LOITER";

// move player into aircraft

waitUntil { _plane distance _targetLoc < 900 or INS_CAS_abortCAS or !alive _plane };

_timeSlept = 0;
while { !INS_CAS_abortCAS && alive _plane } do {
	sleep 1;
	_timeSlept = _timeSlept + 1;

	if (_timeSlept > casPlayerTimeLimit) then { INS_CAS_abortCAS = true; call INS_CAS_finishCAS; } 
	else { hint parseText format["<t color='#6775cf'>%1</t> seconds left", (casPlayerTimeLimit - _timeSlept)]; };
};

// move player back
_pilot = [getPos _plane] call INS_CAS_spawnPilot;
[_plane, _pilot] call INS_CAS_initPlane;

(driver _plane) doMove _originLoc;
waitUntil{ _plane distance _targetLoc >= 2000 || !alive _plane };

{
	deleteVehicle vehicle _x;
	deleteVehicle _x;
} forEach units group _plane;