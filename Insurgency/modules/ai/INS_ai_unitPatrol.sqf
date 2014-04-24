private ["_group", "_distance", "_marker", "_count", "_waypoints", "_slack", "_current", "_wp", "_wp1"];
_distance = 250;
_group = _this;

_group setBehaviour "SAFE";
_group setSpeedMode "LIMITED";
_group setCombatMode "YELLOW";
_group setFormation (["STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "DIAMOND"] call BIS_fnc_selectRandom);

_count = 4 + (floor random 3) + (floor (_distance / 100)); // number of waypoints
_waypoints = [];
_slack = _distance / 5.5;
if (_slack < 20) then { _slack = 20 };
	
while {count _waypoints < _count} do { // Find positions for waypoints
	_position = [getPos leader _group, 40, 100, 0, 0, 20, 0] call BIS_fnc_findSafePos;
	_waypoints = _waypoints + [_position];
};

for "_i" from 1 to (_count - 1) do {
	_current = (_waypoints select _i);

	_waypoint = _group addWaypoint [_current, 0];
	_waypoint setWaypointType "MOVE";
	_waypoint setWaypointCompletionRadius (5 + _slack);
	[_group, _i] setWaypointTimeout [0, 2, 16];
	[_group, _i] setWaypointStatements ["true", "if ((random 3) > 2) then { group this setCurrentWaypoint [(group this), (floor (random (count (waypoints (group this)))))];};"];

	if (debugMode == 1) then {
		private "_m";
		_m = createMarker [format["patrol_wp_%1%2", (floor(_current select 0)), (floor(_current select 1))], _current];
		_m setMarkerShape "Ellipse";
		_m setMarkerSize [20, 20];
		_m setmarkerColor "ColorRed";
	};
};

_wp1 = _group addWaypoint [(_waypoints select 1), 0];
_wp1 setWaypointType "CYCLE";
_wp1 setWaypointCompletionRadius 50;