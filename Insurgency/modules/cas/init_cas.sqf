if (isNil "abortCAS") then { abortCAS = true; };
if (isNil "waitCAS") then { waitCAS = false; };
if (isNil "timeUntilNextCAS") then { timeUntilNextCAS = 0; publicVariable "timeUntilNextCAS"; };

INS_CAS_trackAircraft = {
	_plane = _this select 0;

	_markerName = format ["track%1",random 99999];
	_marker = createMarker[_markerName, [0, 0, 0]];
	_markerName setMarkerType "mil_triangle";
	_markerName setMarkerColor "ColorBLUFOR";

	while { !isNull _plane && alive _plane } do {
		_markerName setMarkerDir (getDir _plane);
		_markerName setMarkerPos (getPos _plane);
		sleep 0.1;
	};

	deleteMarker _marker;
};

CAS_ACTION_ID = player addAction ["<t color='#6775cf'>Request CAS</t>", "insurgency\modules\cas\functions\casMenu.sqf", nil, 1.5, false, false, "", "'ItemGPS' in (assignedItems _this) and 'ItemRadio' in (assignedItems _this)"];