private ["_velocityZ"];

_object = _this select 0;
_distance = _this select 1;
_casType = _this select 2;
_loc = getMarkerPos (_this select 3);
_id = _this select 4;

if (waitCAS) exitWith { hintSilent "CAS already enroute, cancel current CAS or wait for CAS execution before next request!" };
waitCAS = true;

_canceliD = _object addAction ["Cancel CAS", "abortCAS = true;"];
_lockobj = createAgent ["Logic", [(_loc select 0), (_loc select 1), 0], [] , 0 , "CAN_COLLIDE"];
_lockobj setPos _loc;

_lock = getPosASL _lockobj select 2;
_loc = visiblePosition _lockobj;

_dir = random 360;
_dis = 5000;
_ranPos = [(_loc select 0) + _dis * sin _dir, (_loc select 1) + _dis * cos _dir, 260];

_grp = createGroup west;
_buzz = createVehicle ["I_Plane_Fighter_03_CAS_F", _ranPos, [], 100, "FLY"];
[_buzz] execVM "scripts\cas\track.sqf";
_buzz setVectorDir [(_loc select 0) - (getPos _buzz select 0), (_loc select 1) - (getPos _buzz select 1), 0];

sleep 0.2;

_dir = getDir _buzz;
_buzz setVelocity [sin(_dir) * 200, cos(_dir) * 200, 0];
_pilot = _grp createUnit ["B_Pilot_F", _ranPos, [], 0, "FORM"];
_pilot moveinDriver _buzz;
_buzz flyInheight 260;

_buzz setCaptive true;
_buzz allowDamage false;

sleep 0.2;

_grp setBehaviour "STEALTH";
_grp setSpeedMode "FULL";
_grp setCombatMode "BLUE";

(driver _buzz) doMove _loc;

_velocity = velocity _buzz;
_deltax = _velocity select 0;
_deltay = _velocity select 1;

_speed = sqrt (_deltax * _deltax + _deltay * _deltay);
(leader _grp) sideChat format ["Cordinates recieved, CAS (%1) inbound - %2 seconds out", _casType, round (_dis / _speed)];

doCounterMeasure = {
	_plane = _this select 0;
	for "_i" from 1 to 4 do {
		_bool = _plane fireAtTarget [_plane, "CMFlareLauncher"];
		sleep 0.3;
	};

	sleep 3;
	_plane = _this select 0;

	for "_i" from 1 to 4 do {
		_bool = _plane fireAtTarget [_plane, "CMFlareLauncher"];
		sleep 0.3;
	};
};

while {true} do {
	if (_buzz distance _lockobj <= 660) exitwith {};
	if (!alive _buzz) exitwith {};
	if (abortCAS) exitWith {};

	sleep 0.01;
};

if (!alive _buzz) exitwith {
	casRequest = false;
	deleteMarker "CAS_TARGET";
};

waitCAS = false;
if (abortCAS) exitWith {
	_buzz move _ranPos;
	(leader _grp) sideChat "CAS mission aborted";
	_object removeAction _canceliD;
	deleteMarker "CAS_TARGET";

	waitUntil{_buzz distance _object >= 2000 || !alive _buzz};

	{
		deleteVehicle vehicle _x;
		deleteVehicle _x;
	} forEach units _grp;
};

_object removeAction _canceliD;
[_buzz] spawn doCounterMeasure;

_drop = createAgent ["Logic", [getPos _buzz select 0, getPos _buzz select 1, 0], [] , 0 , "CAN_COLLIDE"]; 
_height = 225 + _lock;
_ASL = getPosASL _drop select 2;
_height = _height - _ASL;
_dropped = false;

if ((alive _buzz) && ((_casType == "JDAM") || (_casType == "COMBO"))) then {
	_bomb = "Bo_GBU12_LGB" createvehicle [getPos _drop select 0, getPos _drop select 1, _height];
	_bomb setDir ((_loc select 0)-(getPos _bomb select 0)) atan2 ((_loc select 1)-(getPos _bomb select 1));
	_dist = _bomb distance _loc;

	if (_dist > 536) then {
		_diff = _dist - 536;
		_diff = _diff * 0.150;   
		_velocityZ = 85 - _diff;
	} else {
		_diff = 536 - _dist;
		_diff = _diff * 0.150;   
		_velocityZ = 85 + _diff;
	};

	(leader _grp) sideChat "JDAM away...";
	_bDrop = sqrt(((getPosASL _bomb select 2) -_lock) / 4.9);
	_bVelX = ((_loc select 0) - (getPos _bomb select 0)) / _bDrop;
	_bVelY = ((_loc select 1) - (getPos _bomb select 1)) / _bDrop;
	_bomb setVelocity [_bVelX,_bVelY,(velocity _bomb select 2) - _velocityZ];
	deleteVehicle _drop;
	_dropped = true;
};

if ((alive _buzz) && ((_casType == "CBU") || (_casType == "COMBO"))) then {
	_height = _height + 40;
	_cbu = "Bo_GBU12_LGB" createvehicle [getPos _drop select 0, getPos _drop select 1, _height];
	_cbu setDir ((_loc select 0) - (getPos _cbu select 0)) atan2 ((_loc select 1) - (getPos _cbu select 1));
	_dist = _cbu distance _loc;

	if (_dist > 536) then {
		_diff = _dist - 536;
		_diff = _diff * 0.150;   
		_velocityZ = 85 - _diff;
	} else {
		_diff = 536 - _dist;
		_diff = _diff * 0.150;   
		_velocityZ = 85 + _diff;
	};

	(leader _grp) sideChat "CBU away...";
	_bDrop = sqrt(((getPosASL _cbu select 2)-_lock)/4.9);
	_bVelX = ((_loc select 0) - (getPos _cbu select 0))/_bDrop;
	_bVelY = ((_loc select 1)-(getPos _cbu select 1))/_bDrop;
	_cbu setVelocity [_bVelX, _bVelY, (velocity _cbu select 2) - _velocityZ];
	waitUntil{ getPos _cbu select 2 <= 40 };
	_pos = getPos _cbu;
	_effect = "SmallSecondary" createvehicle _pos;
	deleteVehicle _cbu;

	for "_i" from 1 to 35 do {
		_explo = "G_40mm_HEDP" createvehicle _pos;
		_explo setVelocity [-35 + (random 70),-35 + (random 70),-50];
		sleep 0.025;
	};

	deleteVehicle _drop;
	_dropped = true;
};

deleteVehicle _lockobj;
casRequest = false;
deleteMarker "CAS_TARGET";
_grp = group _buzz;

if !(_dropped) exitWith { (leader _grp) sideChat "unable to deliver ordinance!"; };

_countDown = [] spawn {
	timeUntilNextCAS = casAITimeout;
	while { timeUntilNextCAS > 0 } do {
		sleep 1;
		timeUntilNextCAS = timeUntilNextCAS - 1; 
	};
};

waitUntil{ _buzz distance _object >= 2000 || !alive _buzz };

{
	deleteVehicle vehicle _x;
	deleteVehicle _x;
} forEach units _grp;