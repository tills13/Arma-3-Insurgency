if (isNil "abortCAS") then { abortCAS = true; };
if (isNil "waitCAS") then { waitCAS = false; };
if (isNil "timeUntilNextCAS") then { timeUntilNextCAS = 0; publicVariable "timeUntilNextCAS"; };

CAS_ACTION_ID = player addAction ["<t color='#6775cf'>Request CAS</t>", "insurgency\modules\cas\functions\casMenu.sqf", nil, 1.5, false, false, "", "'ItemGPS' in (assignedItems _this) and 'ItemRadio' in (assignedItems _this)"];