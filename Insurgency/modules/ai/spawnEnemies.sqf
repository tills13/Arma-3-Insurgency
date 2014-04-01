if (isServer) then {
	private ["_enemyType", "_potentialSpawns", "_cities", "_spawnBuilding", "_spawnPosition", "_i", "_m"];

	eos_zone_init; = compile preprocessFileLineNumbers "eos\core\eos_launch.sqf";
	null = [] execVM "eos\core\spawn_fnc.sqf";
	onplayerConnected { [] execVM "eos\Functions\EOS_Markers.sqf"; };

	{
		_cityName = _x select 0;
		_cityPos = _x select 1;
		_cityRadA = _x select 2;

		_numSpawns = 10 max random (_cityRadA / 30);
		_mkr = str _cityName;
		if (getMarkerPos _mkr select 0 == 0) then {
			_marker = format["%1", _cityPos];
			_mkr = createMarker [_marker, _cityPos];
			_mkr setMarkerShape "ELLIPSE";
			_mkr setMarkerType "SOLID";
			_mkr setMarkerSize [_cityRadA, _cityRadA];
			_mkr setMarkerColor "ColorRed";

			//		marker | house | ptrl  | lv    | av   |
			//null = [[markers], hp[grps, size, prob], ptrl[grps, size, prob], lv[grps, size, prob], av[grps, prob], static[grps, prob], helo[grgs, size, prob], [settings]] 
			null = [[_mkr], [3, 2], [5, 2], [3, 3], [0, 0], [2, 50], [2, 3, 5], [0, 1, _cityRadA, EAST, TRUE, TRUE]] call eos_zone_init;
		};
	} forEach (call SL_fnc_urbanAreas);

	null = [["MAINAIRFIELD"], [3, 2], [6, 2], [3, 3], [2, 50], [3, 75], [2, 2, 75], [0, 1, 500, EAST, TRUE, TRUE]] call eos_zone_init; // EXTREME
	null = [["MZONE", "MZONE1", "MZONE2", "MZONE3", "MZONEIMP", "EASTPP"], [4, 2], [4, 2], [3, 2], [2, 50], [3, 75], [2, 3, 25], [0, 1, 500, EAST, TRUE, TRUE]] call eos_zone_init; // HARD
	null = [["NEAIRFIELD", "SAIRFIELD", "AACAIRFIELD", "DESERTAIRFIELD", "MPP", "NISLAND"], [3, 2], [3, 2], [1, 3], [0, 0], [2, 50], [1, 3, 25], [0, 1, 500, EAST, TRUE, TRUE]] call eos_zone_init; // MEDIUM
	null = [["NAIRFIELD", "DAM", "STADIUM", "SWAMP", "MZONE4", "ERUINS", "WINDFARM", "MZONE5", "CHAPEL", "PPWEST", "CASTLE", "WINDFARM1", "NORTHTIP"], [2, 1], [3, 1], [0, 0], [0, 0], [1, 50], [0, 0, 0], [0, 1, 500, EAST, TRUE, TRUE]] call eos_zone_init; // EASY
	null = [["RADIOTOWER", "QUARRY", "MINE", "SLUMS"], [2, 1], [2, 1], [0, 0], [0, 0], [0, 0], [2, 2, 5], [0, 1, 500, EAST, TRUE, TRUE]] call eos_zone_init; // JOKE
	
	proceed = true;
	publicVariable "proceed";
};

