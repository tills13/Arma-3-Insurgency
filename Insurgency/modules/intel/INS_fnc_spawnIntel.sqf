if (isServer) then {
	[] spawn {
		_cities = call SL_fnc_urbanAreas;
		_intelItems = ["Land_Laptop_unfolded_F", "Land_HandyCam_F", "Land_SatellitePhone_F", "Land_SurvivalRadio_F", "Box_East_Ammo_F", "Land_Suitcase_F"];
		
		{
			_cityClassName = _x select 0;
			_cityName = _x select 1;
			_cityPos = _x select 2;
			_cityRadius = (_x select 3) max (_x select 4);

			_cacheBuildings = [_cityPos, _cityRadius] call dl_fnc_findBuildings;

			for "_i" from 1 to INS_intelItems step 1 do {
				if (count _cacheBuildings > 0) then {
					_selectedItem = _intelItems call BIS_fnc_selectRandom; 
					_targetBuilding = _cacheBuildings select (random((count _cacheBuildings) - 1)); // Pull the array and select a random building from it.
					_intelPosition = [_targetBuilding] call getRandomBuildingPosition; // Take the random building from the above result and pass it through gRBP function to get a single cache position

					_laptop = createVehicle [_selectedItem, _intelPosition, [], 0, "None"];
					[_laptop, "Gather Intel", INS_fnc_intelPickup, [], true, true, "true"] call dl_fnc_addActionMP; // might not work - test pls
					_laptop setPos _intelPosition; // Move the intel to the above select position
				};
			};
		} forEach _cities;
	};
};
