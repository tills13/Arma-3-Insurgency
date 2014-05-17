onCacheDestroyed = {
	_cache = _this select 0;
	_killer = _this select 1;
	_legit = true;

	switch (side _killer) do { // check who killed the box
		case west: { INS_west_score = INS_west_score + 1; };
		case east: { INS_west_score = INS_west_score + 1; };
		case resistance: { INS_west_score = INS_west_score + 1; };
		default { _legit = false; call generateNewCache; };
	};

	_pos = getPos cache;
	[_legit, _pos] spawn {
		_legit = _this select 0;
		_pos = _this select 1;

		if (_legit) then {
			for "_i" from 0 to random 10 do { "M_Mo_82mm_AT_LG" createVehicle _pos; sleep 1.0; };
			deleteVehicle cache;
			
			[(parseText format["<t color='#7ba151'>%1/%2</t> ammo caches have been destroyed", INS_west_score, INS_numCaches]), true, false] call dl_fnc_hintMP;

			if (INS_west_score == INS_numCaches) then { // game over
				["All ammo caches have been destroyed", true, true] call dl_fnc_hintMP;
				sleep 20;

				endMission "END1";
			} else {
				{deleteMarker _x} forEach INS_marker_array;
				INS_marker_array = [];
				publicVariable "INS_marker_array";

				call generateNewCache;
			};
		};
	};	
};

generateNewCache = {
	[] spawn {
		_city = (call SL_fnc_urbanAreas) call BIS_fnc_selectRandom;
		_building = ([_city select 2, _city select 3] call SL_fnc_findBuildings) call BIS_fnc_selectRandom;
		_pos = [_building] call getRandomBuildingPosition;

		cache = createVehicle ["Box_East_WpsSpecial_F", _pos, [], 0, "None"];
		cache setPos _pos;

		if (debugMode == 1) then {
			diag_log format ["spawning cache at %1", _pos];
	        _m = createMarker [format ["box%1", random 1000], _pos];
	        _m setMarkerShape "ICON"; 
	        _m setMarkerType "mil_dot";
	        _m setMarkerColor "ColorRed";
		};

		cache addEventHandler ["Killed", "call onCacheDestroyed;"];
		cache addEventHandler ["HandleDamage", {
			_source = _this select 4;
			if ((_source == "SatchelCharge_Remote_Mag") or (_source == "DemoCharge_Remote_Mag")) then { cache setDamage 1 } 
			else { cache setDamage 0 };
		}];

		clearMagazineCargoGlobal cache;
	    clearWeaponCargoGlobal cache;
	    //call fillCacheInventory;

		publicVariable "cache";
	};
};

invItems = ["ItemCompass", "FirstAidKit", "ToolKit", "optic_ACO_grn"];
invAmmo = ["30Rnd_556x45_Stanag", "30Rnd_65x39_caseless_green"];
invWeapons = ["arifle_Katiba_F", "arifle_TRG21_F"];

fillCacheInventory = {
	_cache = cache;

	for "_i" from 0 to random 3 do {
		//_cache addWeaponCargoGlobal [invItems call BIS_fnc_selectRandom, round(random 2)];
		//_cache addWeaponCargoGlobal [invAmmo call BIS_fnc_selectRandom, round(random 4)];
		//_cache addWeaponCargoGlobal [invWeapons call BIS_fnc_selectRandom, 1];
	};
};