private ["_markers", "_intelItems", "_unit", "_nearestPosition", "_pos", "_selectedItem", "_laptop", "_cacheBuildings", "_cities", "_multi", "_intelcount", "_targetBuilding", "_intelPosition", "_i", "_m"];

laptop = [];
publicVariable "laptop";

_intelItems = ["Land_Laptop_unfolded_F", "Land_HandyCam_F", "Land_SatellitePhone_F", "Land_SurvivalRadio_F", "Box_East_Ammo_F", "Land_Suitcase_F"];
_cities = call SL_fnc_urbanAreas;

{
	_cityName = _x select 0;
	_cityPos = _x select 1;
	_cityRadA = _x select 2;
	_cityRadB = _x select 3;
	_cityType = _x select 4;
	_cityAngle = _x select 5;

	if(_cityRadB > _cityRadA) then { _cityRadA = _cityRadB; };

	_cacheBuildings = [_cityPos, _cityRadA] call SL_fnc_findBuildings;

	for "_i" from 1 to intelItems step 1 do {
		if(count _cacheBuildings > 0) then {
			_selectedItem = _intelItems call BIS_fnc_selectRandom; 
			_targetBuilding = _cacheBuildings select (random((count _cacheBuildings)-1)); // Pull the array and select a random building from it.
			_intelPosition = [_targetBuilding] call getRandomBuildingPosition; // Take the random building from the above result and pass it through gRBP function to get a single cache position
			_laptop = createVehicle [_selectedItem, _intelPosition, [], 0, "None"];
			[[_laptop,"<t color='#FF0000'>Gather Intel</t>"],"addactionMP", true, true] spawn BIS_fnc_MP;
			_laptop setPos _intelPosition; // Move the Cache to the above select position
			laptop set [count laptop, _laptop];
			publicVariable "laptop";
		};
	};
} forEach _cities;