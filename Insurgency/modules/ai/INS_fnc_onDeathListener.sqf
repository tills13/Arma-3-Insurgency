//if !(isServer) then { exitWith {}; };

INS_fnc_onDeathListener = {
	_tempRandom = random 100;

	if (_tempRandom > (100 - INS_probOfDrop) || debugMode == 1) then {
		_unit = _this select 0;
		_pos = position _unit;
		_intel = "Land_Suitcase_F" createVehicle _pos;
		_intel setVariable ["INTEL_STRENGTH", (rank _unit) call INS_fn_getRankModifier];

		[_intel] spawn {
			_listen = true;
			_intel = _this select 0;
			_pos = getPos _intel;

			timeSlept = 0;
			while { _listen } do {
				sleep 0.5;
				timeSlept = timeSlept + 0.5;

				if (timeSlept > INS_intelTimeout) then { deleteVehicle _intel; _listen = false; };

				_nearUnits = _pos nearEntities [["CAManBase", "Car"], 2];

				{ 
					if (side _x == west) then {
						[nil, "pickedUpIntel", true, false] spawn BIS_fnc_MP;
						[_intel, "createIntel", false, false] spawn BIS_fnc_MP;
						deleteVehicle _intel;
						_listen = false;
					}; 
				} forEach _nearUnits;	
			};
		};	
	};
};

_unit = _this;
_unit addEventHandler ["Killed", INS_fnc_onDeathListener];
