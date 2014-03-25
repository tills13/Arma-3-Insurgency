_owner  = _this select 0;
_caller = _this select 1;
_id     = _this select 2;
_argArr = _this select 3;

if (timeUntilNextCAS > 0) exitWith { hint format["%1 seconds until CAS is available", timeUntilNextCAS]; };

maxDisReq = (_this select 3) select 0;
casType = (_this select 3) select 1;

_borderMarker = createMarkerLocal["maxDist", getPos _caller];
_borderMarker setMarkerShapeLocal "ELLIPSE";
_borderMarker setMarkerSizeLocal[maxDisReq, maxDisReq];
_borderMarker setMarkerColorLocal "colorRed";
_borderMarker setMarkerBrushLocal "Border";

mapListen = true;
casRequest = false;

timeSlept = 0;
hint "Indicate CAS target by clicking a position on the map.";

while { mapListen } do {
	onMapSingleClick "
		deleteMarker 'CAS_TARGET';
		_marker = createMarker['CAS_TARGET', _pos];
		_marker setMarkerType 'mil_destroy';
		_marker setMarkerSize[0.5, 0.5];
		_marker setMarkerColor 'ColorRed';
		_marker setMarkerText ' TARGET';

		nearTargetList = [];
		nearestVeh = objNull;

		if ((player distance _pos) > maxDisReq) then {
			hintSilent format ['Max distance to target is limited to %1m', maxDisReq];
			deleteMarker 'CAS_TARGET';
		} else { mapListen = false; casRequest = true; abortCAS = false; };

		targetPos = _pos;
		mapclick = true;
		onMapSingleClick '';
		true;
	";

	sleep 0.2;
	timeSlept = timeSlept + 0.2;
	if (timeSlept > 20) then { 
		hint "CAS request timed out";
		mapListen = false; 
	};
};

sleep 0.123;
deleteMarker "maxDist";

if (!casRequest) then {
	deleteMarker "CAS_TARGET";
} else { 
	if (casType != "GAU") then { [_owner, maxDisReq, casType, "CAS_TARGET", _id] execVM "scripts\cas\CASAI.sqf"; }
	else { [_owner, maxDisReq, casType, "CAS_TARGET", _id] execVM "scripts\cas\CASPlayer.sqf"; };
};