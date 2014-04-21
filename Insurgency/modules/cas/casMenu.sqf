player removeAction CAS_ACTION_ID;

INS_CAS_removeMenuItems = {
	private ["player"];
	player = _this select 0;

	player removeAction TITLE_ACTION_ID;
	player removeAction JDAM_ACTION_ID;
	player removeAction CBU_ACTION_ID;
	player removeAction COMBO_ACTION_ID;
	player removeAction GUIDED_ACTION_ID;
	player removeAction A164C_ACTION_ID;
	player removeAction HELI_ACTION_ID;
	player removeAction CAS_CANCEL_ID;

	CAS_ACTION_ID = player addAction ["<t color='#6775cf'>Request CAS</t>", "insurgency\modules\cas\casMenu.sqf", nil, 1.5, false, false];
};

_folderpath = "insurgency\modules\cas\functions\cas_pick_target.sqf";
TITLE_ACTION_ID = player addAction ["<t color='#6775cf'>CAS Options: </t>", "", nil, 1.5, false, false];
JDAM_ACTION_ID = player addAction ["  CAS (JDAM)", _folderpath, [500, "JDAM"]];
CBU_ACTION_ID = player addAction ["  CAS (CBU)", _folderpath, [500, "CBU"]];
COMBO_ACTION_ID = player addAction ["  CAS (JDAM/CBU)", _folderpath, [500, "COMBO"]];
GUIDED_ACTION_ID = player addAction ["  CAS (GUIDED)", _folderpath, [500, "GBU"]];
A164C_ACTION_ID = player addAction ["  CAS (A-164C)", _folderpath, [1000, "GAU"]];
HELI_ACTION_ID = player addAction ["  CAS (Helo)", _folderpath, [1000, "HELO"]];
CAS_CANCEL_ID = player addAction ["  <t color='#ff6347'>Exit CAS Menu</t>", INS_CAS_removeMenuItems, nil, 1.5, false, false];