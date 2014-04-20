#define MAX_SPEED_WHILE_FASTROPING 10
#define MAX_SPEED_ROPES_AVAIL 30

#define STR_TOSS_ROPES "<t color='#6775cf'>Toss Ropes</t>"
#define STR_FAST_ROPE_GROUP "<t color='#7ba151'>Fast Rope (Group)</t>"
#define STR_FAST_ROPE "<t color='#7ba151'>Fast Rope (Group and Pilot)</t>"
#define STR_CUT_ROPES "<t color='#ff6347'>Cut Ropes</t>"

if (isDedicated) exitWith {};
waitUntil {player == player};

INS_heli_rope_ropes = [];
INS_heli_mutexAction = false;

//INS_heli_rope_helis = ["O_Heli_Light_02_unarmed_F", "O_Heli_Light_02_F", "B_Heli_Transport_01_F", "B_Heli_Transport_01_camo_F", "O_Heli_Attack_02_F", "O_Heli_Attack_02_black_F", "I_Heli_Transport_02_F", "B_Heli_Light_01_F"];
INS_heli_rope_helis = ["B_Heli_Light_01_F"];
INS_heli_rope_helidata = [[["O_Heli_Light_02_unarmed_F", "O_Heli_Light_02_F"], [1.35,1.35,-24.95], [-1.45,1.35,-24.95]],
					 [["B_Heli_Transport_01_F", "B_Heli_Transport_01_camo_F"], [-1.11,2.5,-24.7], [1.11,2.5,-24.7]],
					 [["O_Heli_Attack_02_F", "O_Heli_Attack_02_black_F"], [1.3,1.3,-25], [-1.3,1.3,-25]],
					 [["I_Heli_Transport_02_F"], [0,-5,-26], []],
					 [["B_Heli_Light_01_F"], [0.6,0.5,-25.9], [-0.8,0.5,-25.9]]];


INS_heli_fnc_tossRopes = {
	private ["_heli", "_ropes", "_oropes", "_rope"];
	_heli = _this;
	_ropes = [];
	_oropes = _heli getVariable ["INS_heli_ropes", []];
	if (count _oropes != 0 ) exitWith {};
	_i = 0;

	{
		if ((typeof _heli) in (_x select 0)) exitWith {
			_ropes = _ropes + [_x select 1];
			if ( count (_x select 2) !=0 ) then { 
				_ropes = _ropes + [_x select 2];
			};
		};
		_i = _i +1;
	} forEach INS_heli_rope_helidata;
	
	sleep random 0.3;
	if ( count (_heli getVariable ["INS_heli_ropes", []]) != 0 ) exitWith { INS_heli_mutexAction = false; };
	_heli animateDoor ['door_R', 1];
	_heli animateDoor ['door_L', 1];

	{
		_rope = createVehicle ["land_rope_f", [0,0,0], [], 0, "CAN_COLLIDE"];
		_rope setDir (getdir _heli);
		_rope attachTo [_heli, _x];
		_oropes = _oropes + [_rope];
	} forEach _ropes;
	_heli setvariable ["INS_heli_ropes", _oropes, true];
	
	_heli spawn {
		private ["_heli", "_ropes"];
		_heli = _this;

		while {alive _heli and count (_heli getVariable ["INS_heli_ropes", []]) != 0 and abs (speed _heli) < MAX_SPEED_ROPES_AVAIL } do { sleep 0.3; };

		_ropes = (_heli getVariable ["INS_heli_ropes", []]);
		{deleteVehicle _x} forEach _ropes;
		_heli setvariable ["INS_heli_ropes", [], true];
	};
};

INS_heli_fnc_ropes_cond = {
	_veh = vehicle player;
	_flag = (_veh != player) and {(not INS_heli_mutexAction)} and {count (_veh getVariable ["INS_heli_ropes", []]) == 0} and { (typeof _veh) in INS_heli_rope_helis } and {alive player and alive _veh and (abs (speed _veh) < MAX_SPEED_ROPES_AVAIL) };
	_flag;
};

INS_heli_fnc_pilotCanFastRope = {
	_veh = vehicle player;
	_return = false;
	if (_veh != player) then {
		_crew = crew _veh;
		_aiCrew = _crew call INS_fn_getAIArray;

		if (count _aiCrew > 0) exitWith { _return = true };
	};
	
	_return
};

INS_heli_fnc_fastRopeAIUnits = {
	private ["_heli", "_grunits"];

	_heli = _this select 0;
	_grunits = _this select 1;
	
	_heli spawn INS_heli_fnc_tossRopes;

	[_heli, _grunits] spawn {
		private ["_units", "_heli"];
		sleep random 0.5;
		_units = _this select 1;
		_heli = (_this select 0);
		_units = _units - [player];
		_units = _units - [driver _heli];
		{if (!alive _x or isPlayer _x or vehicle _x != _heli) then {_units = _units - [_x];}; } forEach _units;
					
		{ sleep (0.5 + random 0.7); _x spawn INS_heli_fnc_fastRopeUnit; } forEach _units;
		waitUntil {sleep 0.5; { (getpos _x select 2) < 1 } count _units == count _units; };
		sleep 10;
		_heli call INS_heli_fnc_cutropes;
	};
};

INS_heli_fnc_fastRopeGroup = {
	INS_heli_mutexAction = true;
	
	sleep random 0.3;

	if (player == leader group player) then {
		[vehicle player, units group player] call INS_heli_fnc_fastRopeAIUnits;
	};

	INS_heli_mutexAction = false;
};

INS_heli_fnc_fastRope = {
	INS_heli_mutexAction = true;
	if (driver vehicle player == player) then {
		_veh = vehicle player;
		_crew = crew _veh;
		_aiCrew = _crew call INS_fn_getAIArray;
		_newPilot = _aiCrew call BIS_fnc_selectRandom;
		[_newPilot] join grpNull; // so he doesn't leave, too.

		if (player == leader group player) then { [vehicle player, units group player] call INS_heli_fnc_fastRopeAIUnits; };
		player call INS_heli_fnc_fastRopeUnit;

		waitUntil { driver _veh != player; }; // empty

		_newPilot action ["MoveToDriver", _veh]; // get him to hold for a little bit, tho...
		(driver _veh) setBehaviour "Careless";
		(driver _veh) setCombatMode "Blue";
		(driver _veh) disableAI "Target";
		(driver _veh) disableAI "Autotarget";  

		sleep 5.0;
		_veh call INS_heli_fnc_cutropes;
		_veh doMove (getPosATL FLAG);
		_veh flyInHeight 50; 
	} else {
		sleep random 0.3;

		if (player == leader group player) then {
			[vehicle player, units group player] call INS_heli_fnc_fastRopeAIUnits;
		};

		player call INS_heli_fnc_fastRopeUnit;
	};
	
	INS_heli_mutexAction = false;
};

INS_heli_fnc_fastRopeUnit = {
	private ["_unit", "_heli", "_ropes", "_rope", "_zmax", "_zdelta", "_zc"];
	_unit = _this;
	_heli = vehicle _unit;
	if (_unit == _heli) exitWith {};

	_ropes = (_heli getVariable ["INS_heli_ropes", []]);
	if (count _ropes == 0) exitWith {};
	
	_rope = _ropes call BIS_fnc_selectRandom;
	_zmax = 22;
	_zdelta = 7 / 10;
	
	_zc = _zmax;
	_unit action ["eject", _heli];
	_unit switchMove "gunner_standup01";
	
	_unit setpos [(getpos _unit select 0), (getpos _unit select 1), 0 max ((getpos _unit select 2) - 3)];
	while {alive _unit and (getpos _unit select 2) > 1 and (abs (speed _heli)) < MAX_SPEED_WHILE_FASTROPING  and _zc > -24} do {
		_unit attachTo [_rope, [0, 0, _zc]];
		_zc = _zc - _zdelta;
		sleep 0.1;
	};

	_unit switchMove "";
	detach _unit;
};

INS_heli_fnc_cutropes = {
	_veh = _this;
	_ropes = (_veh getVariable ["INS_heli_ropes", []]);
	{deleteVehicle _x} forEach _ropes;
	_veh setvariable ["INS_heli_ropes", [], true];
	_veh animateDoor ['door_R', 0];
	_veh animateDoor ['door_L', 0];
};

INS_heli_fnc_removeropes = {
	(vehicle player) call INS_heli_fnc_cutropes;
};

INS_heli_fnc_createropes = {
	INS_heli_mutexAction = true;
	(vehicle player) call INS_heli_fnc_tossRopes;
	INS_heli_mutexAction = false;
};

/*[] spawn {
	while { true } do {
		sleep 1;
		player sideChat str random 5;
		player sideChat str call compile "(player != driver vehicle player)";
		player sideChat str call compile "(call INS_heli_fnc_pilotCanFastRope)";
	};
};*/

player addAction[STR_TOSS_ROPES, INS_heli_fnc_createropes, [], 1.5, false, false, '','[] call INS_heli_fnc_ropes_cond'];
player addAction[STR_CUT_ROPES, INS_heli_fnc_removeropes, [], 1.5, false, false, '','not INS_heli_mutexAction and count ((vehicle player) getVariable ["INS_heli_ropes", []]) != 0'];
player addAction[STR_FAST_ROPE, INS_heli_fnc_fastRope, [], 1.5, false, false, '','not INS_heli_mutexAction and count ((vehicle player) getVariable ["INS_heli_ropes", []]) != 0 and ((player != driver vehicle player) or (call INS_heli_fnc_pilotCanFastRope))'];
player addAction[STR_FAST_ROPE_GROUP, INS_heli_fnc_fastRopeGroup, [], 1.5, false, false, '','not INS_heli_mutexAction and count ((vehicle player) getVariable ["INS_heli_ropes", []]) != 0 and ((player != driver vehicle player) or (call INS_heli_fnc_pilotCanFastRope))'];

player addEventHandler ["Respawn", {
	player addAction[STR_TOSS_ROPES, INS_heli_fnc_createropes, [], 1.5, false, false, '','[] call INS_heli_fnc_ropes_cond'];
	player addAction[STR_CUT_ROPES, INS_heli_fnc_removeropes, [], 1.5, false, false, '','not INS_heli_mutexAction and count ((vehicle player) getVariable ["INS_heli_ropes", []]) != 0'];
	player addAction[STR_FAST_ROPE, INS_heli_fnc_fastRope, [], 1.5, false, false, '','not INS_heli_mutexAction and count ((vehicle player) getVariable ["INS_heli_ropes", []]) != 0 and ((player != driver vehicle player) or (call INS_heli_fnc_pilotCanFastRope))'];
	player addAction[STR_FAST_ROPE_GROUP, INS_heli_fnc_fastRopeGroup, [], 1.5, false, false, '','not INS_heli_mutexAction and count ((vehicle player) getVariable ["INS_heli_ropes", []]) != 0 and ((player != driver vehicle player) or (call INS_heli_fnc_pilotCanFastRope))'];
}];