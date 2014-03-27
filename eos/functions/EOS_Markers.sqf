_eosMarkers = server getVariable "EOSmarkers";

{
	_x setMarkerAlpha (MarkerAlpha _x);
	_x setMarkercolor (getMarkercolor _x);
} forEach _eosMarkers;
