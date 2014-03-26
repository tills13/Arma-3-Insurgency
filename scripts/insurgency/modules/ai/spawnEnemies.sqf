if (isServer) then {
	private ["_enemyType", "_potentialSpawns", "_cities", "_spawnBuilding", "_spawnPosition", "_i", "_m"];


	EOS_Spawn = compile preprocessfilelinenumbers "eos\core\eos_launch.sqf";
	null = [] execVM "eos\core\spawn_fnc.sqf";
	onplayerConnected { [] execVM "eos\Functions\EOS_Markers.sqf"; };

	_cities = call SL_fnc_urbanAreas;

	{
		_cityName = _x select 0;
		_cityPos = _x select 1;
		_cityRadA = _x select 2;

		_numSpawns = 10 max random (_cityRadA / 30);

		for "_i" from 1 to _numSpawns do {
			_pos = + _cityPos;
			_posx = _pos select 0;
			_posy = _pos select 1;

			_xmult = 1;
			_ymult = 1;
			if (random 1 > 0.5) then { _xmult = -1; };
			if (random 1 > 0.5) then { _ymult = -1; };
			_pos set [0, _posx + random (_cityRadA / 1.5) * _xmult];
			_pos set [1, _posy + random (_cityRadA / 1.5) * _ymult];

		 	_x = _pos select 0;
		 	_y = _pos select 1;
		 	_x = _x - (_x % 100);
		 	_y = _y - (_y % 100);
		 	_markerPos = [_x + 50, _y + 50, 0];

			_mkr = str _markerPos;
			if (getMarkerPos _mkr select 0 == 0) then {
				_marker = format["%1", _markerPos];
				_mkr = createMarker [_marker, _markerPos];
				_mkr setMarkerShape "RECTANGLE";
				_mkr setMarkerType "SOLID";
				if (debugMode) then { _mkr setMarkerText "units" };
				_mkr setMarkerSize [50, 50];
				_mkr setMarkerColor "ColorRed";

				null = [[_mkr], [1, 2, 25], [1, 2, 25], [1, 0, 10], [0], [2, 1, 10], [1, 4, 5], [0, 2, 500, EAST, TRUE, TRUE, TRUE]] call EOS_Spawn;
			};
		};

		for "_i" from 1 to (round (random 3)) do {
			_pos = + _cityPos;
			_posx = _pos select 0;
			_posy = _pos select 1;

			_xmult = 1;
			_ymult = 1;
			if (random 1 > 0.5) then { _xmult = -1; };
			if (random 1 > 0.5) then { _ymult = -1; };
			_pos set [0, _posx + random (_cityRadA / 1.5) * _xmult];
			_pos set [1, _posy + random (_cityRadA / 1.5) * _ymult];

		 	_x = _pos select 0;
		 	_y = _pos select 1;
		 	_x = _x - (_x % 100);
		 	_y = _y - (_y % 100);
		 	_markerPos = [_x + 50, _y + 50, 0];

			_mkr = str _markerPos;
			if (getMarkerPos _mkr select 0 == 0) then {
				_marker = format["%1", _markerPos];
				_mkr = createMarker [_marker, _markerPos];
				_mkr setMarkerShape "RECTANGLE";
				_mkr setMarkerType "SOLID";
				if (debugMode) then { _mkr setMarkerText "helicopters" };
				_mkr setMarkerSize [50, 50];
				_mkr setMarkerColor "ColorBlue";

				//null = [[_mkr], [1, 2, 25], [1, 2, 25], [1, 0, 10], [0], [2, 1, 10], [1, 4, 5], [0, 2, 500, EAST, TRUE, TRUE]] call EOS_Spawn;
				null = [[_mkr], [0, 0, 0], [1, 1, 25], [0, 0, 0], [0, 0, 0], [1, 4, 100], [0, 2, 500, EAST, FALSE, TRUE]] call EOS_Spawn;
			};
		};

		for "_i" from 1 to (random 5) do {
			_pos = + _cityPos;
			_posx = _pos select 0;
			_posy = _pos select 1;

			_xmult = 1;
			_ymult = 1;
			if (random 1 > 0.5) then { _xmult = -1; };
			if (random 1 > 0.5) then { _ymult = -1; };
			_pos set [0, _posx + random (_cityRadA / 1.5) * _xmult];
			_pos set [1, _posy + random (_cityRadA / 1.5) * _ymult];

			_x = _pos select 0;
		 	_y = _pos select 1;
		 	_x = _x - (_x % 100);
		 	_y = _y - (_y % 100);
		 	_markerPos = [_x + 50, _y + 50, 0];

			_mkr = str _markerPos;

			if (getMarkerPos _mkr select 0 == 0) then {
				_marker = format["%1", _markerPos];
				_mkr = createMarker [_marker, _markerPos];
				_mkr setMarkerShape "RECTANGLE";
				_mkr setMarkerType "SOLID";
				if (debugMode) then { _mkr setMarkerText "vehicles" };
				_mkr setMarkerSize [50, 50];
				_mkr setMarkerColor "ColorRed";

				null = [[_mkr], [1, 1, 75], [2, 2, 75], [1, 1, 100], [1, 1, 100], [0, 0, 0], [0, 2, 500, EAST, TRUE, TRUE]] call EOS_Spawn;
			};
		};
	} forEach _cities;
};

