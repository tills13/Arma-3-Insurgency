_object = _this select 0;
_distance = _this select 1;
_loc = getMarkerPos (_this select 2);
_locOrig = getMarkerPos (_this select 3);
_id = _this select 4;

if (waitCAS) exitWith { hintSilent "CAS already enroute, cancel current CAS or wait for CAS execution before next request!" };
waitCAS = true;

_cancelID = player addAction ["Done", "abortCAS = true;"];

_helo = createVehicle ["B_Heli_Attack_01_F", _locOrig, [], 0, "FLY"];
[_helo] execVM "cas\functions\track.sqf";
_helo setVectorDir [(_loc select 0) - (getPos _helo select 0), (_loc select 1) - (getPos _helo select 1), 0];

_grp = createGroup west;
_pilot = _grp createUnit ["B_Pilot_F", _loc, [], 0, "FORM"];
_pilot moveInDriver _helo;
_helo flyInheight 100;

_grp setBehaviour "MOVE";
_grp setSpeedMode "FULL";
_grp setCombatMode "BLUE";

_playerOrigLoc = getPos player;
player moveInGunner _helo;

_wp = group _helo addWaypoint [_loc, 0];
_wp setWaypointType "LOITER";

while { true } do {
	if (_helo distance _loc < 900 or abortCAS or !alive _helo) exitWith {};
};

_timeSlept = 0;
casPlayerTimeLimit = 90;
while {!abortCAS && alive _helo} do {
	sleep 1;
	_timeSlept = _timeSlept + 1;

	if (_timeSlept > casPlayerTimeLimit) then { abortCAS = true; } 
	else { hint format["%1 seconds left", [casPlayerTimeLimit - _timeSlept]]; };
};

deleteWaypoint _wp;
player removeAction _cancelID;
_helo move _locOrig; // move back to original location
player setPos _playerOrigLoc;
deleteMarker "CAS_TARGET";
deleteMarker "CAS_ORIG";

_countDown = [] spawn {
	timeUntilNextCAS = casPlayerTimeout;
	while { timeUntilNextCAS > 0 } do {
		sleep 1;
		timeUntilNextCAS = timeUntilNextCAS - 1; 
		publicVariable "timeUntilNextCAS";
	};
};

waitUntil{ _helo distance _object >= 2000 || !alive _helo };

{
	deleteVehicle vehicle _x;
	deleteVehicle _x;
} forEach units _grp;

waitCAS = false;
casRequest = false;