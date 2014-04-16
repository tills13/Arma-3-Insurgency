/*---------------------------------------------*/

_eosMarkers = server getVariable "EOSmarkers";

{
	_markers = [];
	_mpos = getMarkerPos _x;
	_mradius = getMarkerSize _x;

	_posX = _mpos select 0;
	_posY = _mpos select 1;

	_radiusX = _mradius select 0;
	_radiusY = _mradius select 1;

	for "_rangeX" from (_posX - _radiusX - 100) to (_posX + _radiusX + 100) do {
		for "_rangeY" from (_posY - _radiusY - 100) to (_posY + _radiusY + 100) do {
			_pos = [_rangeX, _rangeY, 0];
			if ((_pos distance _mpos) < (_radiusX min _radiusY)) then {
				_x = _pos select 0;
			 	_y = _pos select 1;
			 	_x = _x - (_x % 100);
			 	_y = _y - (_y % 100);
				_pos = [_x + 50, _y + 50, 0];
				_mkr = str _pos;

				if (getMarkerPos _mkr select 0 == 0) then {
					_mkr = createMarkerLocal[_mkr, _pos];
					_mkr setMarkerShapeLocal "RECTANGLE";
					_mkr setMarkerTypeLocal "SOLID";
					_mkr setMarkerSizeLocal [50, 50];
					_mkr setMarkerColor "ColorRed";
					_mkr setMarkerAlphaLocal 0.5;

					_markers = _markers + [_mkr];
				};
			};
			
			_rangeY = _rangeY + 50;
		};

		_rangeX = _rangeX + 50;
	};

	_trigE = createTrigger ["EmptyDetector", _mpos ];
	_trigE setTriggerActivation ["WEST", "PRESENT", false];
	_trigE setTriggerArea [_radiusX, _radiusY, 0, false];
	_trigE setTriggerStatements ["this", format["%1 call SL_fnc_createTriggers", _markers], ""];
} forEach _eosMarkers;