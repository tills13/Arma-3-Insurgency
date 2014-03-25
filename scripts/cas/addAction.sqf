_object = _this select 0;
_maxDist = _this select 1;

_object addAction ["Request CAS (JDAM)", "scripts\cas\casMenu.sqf", [_maxDist, "JDAM"]];
_object addAction ["Request CAS (GBU)", "scripts\cas\casMenu.sqf", [_maxDist, "GBU"]];
_object addAction ["Request CAS (JDAM/GBU)", "scripts\cas\casMenu.sqf", [_maxDist, "COMBO"]];
_object addAction ["Request CAS (A-164C)", "scripts\cas\casMenu.sqf", [_maxDist, "GAU"]];