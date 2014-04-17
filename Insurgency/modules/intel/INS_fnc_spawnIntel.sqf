if (isServer) then {
	laptop = [];
	publicVariable "laptop";

	addPickupActionMP = {
		_intel = _this;
		_intel addaction ["<t color='#FF0000'>Gather Intel</t>", "call intelPickup"];
	};

	[] spawn {
		_cities = call SL_fnc_urbanAreas;
		_intelItems = ["Land_Laptop_unfolded_F", "Land_HandyCam_F", "Land_SatellitePhone_F", "Land_SurvivalRadio_F", "Box_East_Ammo_F", "Land_Suitcase_F"];
		
		{
			_cityName = _x select 0;
			_cityPos = _x select 1;
			_cityRadA = _x select 2;
			_cityRadB = _x select 3;
			_cityType = _x select 4;
			_cityAngle = _x select 5;

			if(_cityRadB > _cityRadA) then { _cityRadA = _cityRadB; };

			_cacheBuildings = [_cityPos, _cityRadA] call SL_fnc_findBuildings;

			for "_i" from 1 to INS_intelItems step 1 do {
				if (count _cacheBuildings > 0) then {
					_selectedItem = _intelItems call BIS_fnc_selectRandom; 
					_targetBuilding = _cacheBuildings select (random((count _cacheBuildings) - 1)); // Pull the array and select a random building from it.
					_intelPosition = [_targetBuilding] call getRandomBuildingPosition; // Take the random building from the above result and pass it through gRBP function to get a single cache position

					_laptop = createVehicle [_selectedItem, _intelPosition, [], 0, "None"];
					[_laptop, "addPickupActionMP", true, true] spawn BIS_fnc_MP;
					_laptop setPos _intelPosition; // Move the intel to the above select position

					if (debugMode == 1) then {
						_m = createMarker [format ["intel%1", random 1000], _intelPosition];
			            _m setMarkerShape "ICON"; 
			            _m setMarkerType "mil_dot";
			            _m setMarkerColor "ColorRed";
					};

					laptop = laptop + [_laptop];
					publicVariable "laptop";
				};
			};
		} forEach _cities;
	};
};
