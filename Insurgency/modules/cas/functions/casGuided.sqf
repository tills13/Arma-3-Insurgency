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

_laserLoc = locationNULL;
_notifyLaser = true;
_notifyTarget = true;

while {true} do {
	_laserLoc = laserTarget player;
	if (_plane distance _lockobj <= 1000 && _notifyLaser) then { (leader _grp) sideChat "Laser target..."; _notifyLaser = false; };
	if (_plane distance _lockobj <= 1000 && !(_notifyLaser) && _notifyTarget && !isNull _laserLoc) then { (leader _grp) sideChat "Target acquired..."; _notifyTarget = false; };
	if (_plane distance _lockobj <= 1000 && !(_notifyLaser) && !(_notifyTarget) && isNull _laserLoc) then { (leader _grp) sideChat "Target lost!"; _notifyTarget = true; };

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

while {alive _bomb} do {
	if !(isNull (laserTarget player)) then { _laserLoc = laserTarget player; };
	_velocityForCheck = [_bomb, _laserLoc] call INS_CAS_homeMissile;
	if ({(typeName _x) == (typeName 0)} count _velocityForCheck == 3) then { _bomb setVelocity _velocityForCheck };
	hint str getPos _bomb;
	sleep 1.0;
};

deleteWaypoint _wp;
(driver _plane) doMove _originLoc;
waitUntil{ _plane distance _targetLoc >= 2000 || !alive _plane };

{
	deleteVehicle vehicle _x;
	deleteVehicle _x;
} forEach units group _plane;