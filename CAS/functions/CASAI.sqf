private ["_velocityZ"];

_object = _this select 0;
_distance = _this select 1;
_casType = _this select 2;
_loc = getMarkerPos (_this select 3);
_locOrig = getMarkerPos (_this select 4);
_id = _this select 5;

if (waitCAS) exitWith { hintSilent "CAS already enroute, cancel current CAS or wait for CAS execution before next request!" };
waitCAS = true;

_canceliD = player addAction ["Cancel CAS", "abortCAS = true;"];
_lockobj = createAgent ["Logic", [(_loc select 0), (_loc select 1), 0], [] , 0 , "CAN_COLLIDE"];
_lockobj setPos _loc;

_lock = getPosASL _lockobj select 2;
_loc = visiblePosition _lockobj;

_dis = _loc distance _locOrig;
_ranPos = _locOrig;

_grp = createGroup west;
_buzz = createVehicle ["I_Plane_Fighter_03_CAS_F", _ranPos, [], 100, "FLY"];
[_buzz] execVM "cas\functions\track.sqf";
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

_laserLoc = locationNULL;
_isGBU = if (casType == "GBU") then {true} else {false};
_notifyLaser = true;
_notifyTarget = true;
while {true} do {
	if (_isGBU) then {
		_laserLoc = laserTarget player;
		if (_buzz distance _lockobj <= 1000 && _notifyLaser) then { (leader _grp) sideChat "Laser target..."; _notifyLaser = false; };
		if (_buzz distance _lockobj <= 1000 && !(_notifyLaser) && _notifyTarget && !isNull _laserLoc) then { (leader _grp) sideChat "Target acquired..."; _notifyTarget = false; };
		if (_buzz distance _lockobj <= 1000 && !(_notifyLaser) && !(_notifyTarget) && isNull _laserLoc) then { (leader _grp) sideChat "Target lost!"; _notifyTarget = true; };
	};
	
	if (_buzz distance _lockobj <= 660) exitwith {};
	if (!alive _buzz) exitwith {};
	if (abortCAS) exitWith {};

	sleep 0.01;
};

if (!alive _buzz) exitwith {
	casRequest = false;
	deleteMarker "CAS_TARGET";
	deleteMarker "CAS_ORIG";
};

waitCAS = false;
if (abortCAS) exitWith {
	_buzz move _locOrig;
	(leader _grp) sideChat "CAS mission aborted";
	player removeAction _canceliD;
	deleteMarker "CAS_TARGET";
	deleteMarker "CAS_ORIG";

	waitUntil{_buzz distance _object >= 2000 || !alive _buzz};

	{
		deleteVehicle vehicle _x;
		deleteVehicle _x;
	} forEach units _grp;
};

player removeAction _canceliD;
[_buzz] spawn doCounterMeasure;

_drop = createAgent ["Logic", [getPos _buzz select 0, getPos _buzz select 1, 0], [] , 0 , "CAN_COLLIDE"]; 
_height = 225 + _lock;
_ASL = getPosASL _drop select 2;
_height = _height - _ASL;
_dropped = false;

if ((alive _buzz) && ((_casType == "JDAM") || (_casType == "COMBO"))) then {
	_bomb = "Bo_GBU12_LGB" createVehicle [getPos _drop select 0, getPos _drop select 1, _height];
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
	_cbu = "Bo_GBU12_LGB" createVehicle [getPos _drop select 0, getPos _drop select 1, _height];
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
	_effect = "SmallSecondary" createVehicle _pos;
	deleteVehicle _cbu;

	for "_i" from 1 to 35 do {
		_explo = "G_40mm_HEDP" createVehicle _pos;
		_explo setVelocity [-35 + (random 70),-35 + (random 70),-50];
		sleep 0.025;
	};

	deleteVehicle _drop;
	_dropped = true;
};

_homeMissile = {
	private ["_velocityX", "_velocityY", "_velocityZ", "_target"];
	_bomb = _this select 0;
	_target = _this select 1;
	_bombSpeed = 100;

	if (_bomb distance _target > (_bombSpeed / 20)) then {
		_travelTime = (_target distance _bomb) / _bombSpeed;

		_relDirHor = [_bomb, _target] call BIS_fnc_DirTo;
		_bomb setDir _relDirHor;

		_relDirVer = asin ((((getPosASL _bomb) select 2) - ((getPosASL _target) select 2)) / (_target distance _bomb));
		_relDirVer = (_relDirVer * -1);
		[_bomb, _relDirVer, 0] call BIS_fnc_setPitchBank;

		_velocityX = (((getPosASL _target) select 0) - ((getPosASL _bomb) select 0)) / _travelTime;
		_velocityY = (((getPosASL _target) select 1) - ((getPosASL _bomb) select 1)) / _travelTime;
		_velocityZ = (((getPosASL _target) select 2) - ((getPosASL _bomb) select 2)) / _travelTime;
	};

	[_velocityX, _velocityY, _velocityZ]
};

if ((alive _buzz) && (_casType == "GBU")) then {
	if !(isNull _laserLoc) then {
		_bomb = "Bo_GBU12_LGB" createVehicle [getPos _drop select 0, getPos _drop select 1, _height];
		_bomb setDir ((_loc select 0)-(getPos _bomb select 0)) atan2 ((_loc select 1)-(getPos _bomb select 1));

		(leader _grp) sideChat "GBU away...";
		while {alive _bomb} do {
			if !(isNull (laserTarget player)) then { _laserLoc = laserTarget player; };
			_velocityForCheck = [_bomb, _laserLoc] call _homeMissile;
			if ({(typeName _x) == (typeName 0)} count _velocityForCheck == 3) then { _bomb setVelocity _velocityForCheck };
			hint str getPos _bomb;
			sleep 1.0;
		};

		deleteVehicle _drop;
		_dropped = true;
	};
};

deleteVehicle _lockobj;
casRequest = false;
deleteMarker "CAS_TARGET";
deleteMarker "CAS_ORIG";
_grp = group _buzz;

if !(_dropped) exitWith { (leader _grp) sideChat "unable to deliver ordinance!"; };

_countDown = [] spawn {
	timeUntilNextCAS = casAITimeout;
	while { timeUntilNextCAS > 0 } do {
		sleep 1;
		timeUntilNextCAS = timeUntilNextCAS - 1; 
		publicVariable "timeUntilNextCAS";
	};
};

waitUntil{ _buzz distance _object >= 2000 || !alive _buzz };

{
	deleteVehicle vehicle _x;
	deleteVehicle _x;
} forEach units _grp;