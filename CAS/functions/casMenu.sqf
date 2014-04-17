_object = _this select 0;
_caller = _this select 1;
_maxDist = _this select 2;

_object removeAction CAS_ACTION_ID;

removeActions = {
	private ["_object"];
	_object = _this select 0;

	_object removeAction TITLE_ACTION_ID;
	_object removeAction JDAM_ACTION_ID;
	_object removeAction CBU_ACTION_ID;
	_object removeAction COMBO_ACTION_ID;
	_object removeAction GUIDED_ACTION_ID;
	_object removeAction A164C_ACTION_ID;
	_object removeAction HELI_ACTION_ID;
	_object removeAction CAS_CANCEL_ID;

	CAS_ACTION_ID = _object addAction ["<t color='#6775cf'>Request CAS</t>", "cas\functions\casMenu.sqf", nil, 1.5, false, false];
};

_folderpath = "cas\functions\designateCASTarget.sqf";
TITLE_ACTION_ID = _object addAction ["<t color='#6775cf'>CAS Options: </t>", "", nil, 1.5, false, false];
JDAM_ACTION_ID = _object addAction ["  CAS (JDAM)", _folderpath, [500, "JDAM"]];
CBU_ACTION_ID = _object addAction ["  CAS (CBU)", _folderpath, [500, "CBU"]];
COMBO_ACTION_ID = _object addAction ["  CAS (JDAM/CBU)", _folderpath, [500, "COMBO"]];
GUIDED_ACTION_ID = _object addAction ["  CAS (GUIDED)", _folderpath, [500, "GBU"]];
A164C_ACTION_ID = _object addAction ["  CAS (A-164C)", _folderpath, [1000, "GAU"]];
HELI_ACTION_ID = _object addAction ["  CAS (Helo)", _folderpath, [1000, "HELO"]];
CAS_CANCEL_ID = _object addAction ["  <t color='#ff6347'>Exit CAS Menu</t>", removeActions, nil, 1.5, false, false];