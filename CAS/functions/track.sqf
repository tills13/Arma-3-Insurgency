_plane = _this select 0;

_markerName = format ["track%1",random 99999];
_marker = createMarker[_markerName, [0, 0, 0]];
_markerName setMarkerType "mil_triangle";
_markerName setMarkerColor "ColorBLUFOR";

while {!isNull _plane && alive _plane} do {
	_markerName setMarkerDir (getDir _plane);
	_markerName setMarkerPos (getPos _plane);
	sleep 0.1;
};

deleteMarker _marker;