_object = _this select 0;
_maxDist = _this select 1;


_folder_path = "cas\functions\casMenu.sqf"
_object addAction ["Request CAS (JDAM)", _folder_path, [_maxDist, "JDAM"]];
_object addAction ["Request CAS (CBU)", _folder_path, [_maxDist, "CBU"]];
_object addAction ["Request CAS (JDAM/CBU)", _folder_path, [_maxDist, "COMBO"]];
_object addAction ["Request CAS (GUIDED)", _folder_path, [_maxDist, "GBU"]];
_object addAction ["Request CAS (A-164C)", _folder_path, [_maxDist, "GAU"]];