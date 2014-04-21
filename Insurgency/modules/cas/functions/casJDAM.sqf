if (INS_CAS_waitCAS) exitWith { hintSilent "CAS already enroute, cancel current CAS or wait for CAS execution before next request!" };
INS_CAS_waitCAS = true; publicVariable "INS_CAS_waitCAS";

_targetLoc = getMarkerPos "CAS_TARGET";
_originLoc = getMarkerPos "CAS_ORIG";

INS_cancel_AID = player addAction ["Cancel CAS", "INS_CAS_abortCAS = true;"];

_plane = [nil, _originLoc, _targetLoc] call INS_CAS_spawnAircraft;
_pilot = [_originLoc] call INS_CAS_spawnPilot;
[_plane, _pilot] call INS_CAS_initPlane;

(driver _plane) doMove _targetLoc;
[_plane] call INS_CAS_notifyETA;

while {true} do {
	if (_plane distance _targetLoc <= 660) exitwith {};
	if (!alive _plane) exitwith {};
	if (INS_CAS_abortCAS) exitWith {};

	sleep 0.1;
};

if (!alive _plane) exitwith { call INS_CAS_finishCAS; };
if (INS_CAS_abortCAS) exitWith {
	(leader _grp) sideChat "CAS mission aborted";
	call INS_CAS_finishCAS;

	_plane move _originLoc;
	waitUntil { _plane distance _targetLoc >= 2000 || !alive _plane };

	{
		deleteVehicle vehicle _x;
		deleteVehicle _x;
	} forEach units _grp;
};

[_plane] spawn INS_CAS_doCounterMeasure;
_bomb = [_plane, "Bo_GBU12_LGB"] call INS_CAS_createOrdinance;
[120] spawn INS_CAS_casTimeOut;
call INS_CAS_finishCAS;

(driver _plane) doMove _originLoc;
waitUntil{ _plane distance _targetLoc >= 2000 || !alive _plane };

{
	deleteVehicle vehicle _x;
	deleteVehicle _x;
} forEach units group _plane;