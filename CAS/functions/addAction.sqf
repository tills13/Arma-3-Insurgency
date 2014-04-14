_object = _this select 0;
_maxDist = _this select 1;

_folderpath = "cas\functions\casMenu.sqf";
_object addAction ["Request CAS (JDAM)", _folderpath, [_maxDist, "JDAM"]];
_object addAction ["Request CAS (CBU)", _folderpath, [_maxDist, "CBU"]];
_object addAction ["Request CAS (JDAM/CBU)", _folderpath, [_maxDist, "COMBO"]];
_object addAction ["Request CAS (GUIDED)", _folderpath, [_maxDist, "GBU"]];
_object addAction ["Request CAS (A-164C)", _folderpath, [_maxDist + 500, "GAU"]];
_object addAction ["Request CAS (Helo)", _folderpath, [_maxDist + 500, "HELO"]];