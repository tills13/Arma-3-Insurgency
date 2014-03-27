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
_borderMarker setMarkerColorLocal "ColorRed";
_borderMarker setMarkerBrushLocal "Border";

_borderMarker = createMarkerLocal["minDistOrig", getPos _caller];
_borderMarker setMarkerShapeLocal "ELLIPSE";
_borderMarker setMarkerSizeLocal[3000, 3000];
_borderMarker setMarkerColorLocal "ColorBlue";
_borderMarker setMarkerBrushLocal "Border";

mapListen = true;
casRequest = false;

timeSlept = 0;
hint "Indicate CAS target by shift-clicking a position on the map, then alt-click to choose where the CAS will originate from (straight line from that point)";

targetPos = [];
origPos = [];

while { mapListen } do {
	onMapSingleClick "
		if (_shift) then {
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
			} else { 
				targetPos = _pos;
				if (!(str targetPos == '[]') && !(str origPos == '[]')) then {
					mapListen = false; casRequest = true; abortCAS = false;
				}; 
			};

			onMapSingleClick '';
		};

		if (_alt) then {
			deleteMarker 'CAS_ORIG';
			_marker = createMarker['CAS_ORIG', _pos];
			_marker setMarkerType 'mil_destroy';
			_marker setMarkerSize[0.5, 0.5];
			_marker setMarkerColor 'ColorBlue';
			_marker setMarkerText ' ORIGIN';

			nearTargetList = [];
			nearestVeh = objNull;

			if ((player distance _pos) < 3000) then {
				hintSilent format ['Min distance from target is limited to %1m', 3000];
				deleteMarker 'CAS_ORIG';
			} else { 
				origPos = _pos;
				if (!(str targetPos == '[]') && !(str origPos == '[]')) then {
					mapListen = false; casRequest = true; abortCAS = false;
				};
			};

			onMapSingleClick '';
		}; 

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
deleteMarker "minDistOrig";

if (!casRequest) then {
	deleteMarker "CAS_TARGET";
	deleteMarker "CAS_ORIG";
} else { 
	if (casType != "GAU") then { [_owner, maxDisReq, casType, "CAS_TARGET", "CAS_ORIG", _id] execVM "scripts\cas\CASAI.sqf"; }
	else { [_owner, maxDisReq, casType, "CAS_TARGET", "CAS_ORIG", _id] execVM "scripts\cas\CASPlayer.sqf"; };
};