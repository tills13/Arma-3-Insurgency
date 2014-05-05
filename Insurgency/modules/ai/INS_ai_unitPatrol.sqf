private ["_group", "_marker", "_count", "_waypoints", "_slack", "_current", "_wp", "_wp1"];
if (isNil "INS_ai_patrol") then { INS_ai_patrol = compile preprocessfile "insurgency\modules\ai\INS_ai_unitPatrol.sqf"; };

_group = _this;

_group setBehaviour "SAFE";
_group setSpeedMode "LIMITED";
_group setCombatMode "YELLOW";
_group setFormation (["STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "DIAMOND"] call BIS_fnc_selectRandom);

_position = [getPos leader _group, 100, 200, 0, 0, 20, 0] call BIS_fnc_findSafePos;
_waypoint = _group addWaypoint [_position, 0, 0];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointCompletionRadius 10;
_waypoint setWaypointStatements ["true", "(group this) call INS_ai_patrol;"];

if (debugMode == 1) then {
	_m = createMarker ["patrol_wp", _position];
	_m setMarkerShape "Ellipse";
	_m setMarkerSize [20, 20];
	_m setmarkerColor "ColorRed";
};