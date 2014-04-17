if (isNil "abortCAS") then { abortCAS = true; };
if (isNil "waitCAS") then { waitCAS = false; };
if (isNil "timeUntilNextCAS") then { timeUntilNextCAS = 0; publicVariable "timeUntilNextCAS"; };
_object = _this select 0;

CAS_ACTION_ID = _object addAction ["<t color='#6775cf'>Request CAS</t>", "cas\functions\casMenu.sqf", nil, 1.5, false, false];