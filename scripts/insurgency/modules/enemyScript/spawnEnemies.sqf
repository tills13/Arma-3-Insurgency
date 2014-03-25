private ["_enemyType", "_potentialSpawns", "_cities", "_spawnBuilding", "_spawnPosition", "_i", "_m"];

_enemyVariants = ["O_Soldier_F", "O_officer_F", "O_Soldier_AR_F", "O_medic_F", "O_soldierU_AA_F", "O_soldierU_repair_F"];
_cities = call SL_fnc_urbanAreas;

{
	_cityName = _x select 0;
	_cityPos = _x select 1;
	_cityRadA = _x select 2;
	_cityRadB = _x select 3;
	_cityType = _x select 4;
	_cityAngle = _x select 5;

	if(_cityRadB > _cityRadA) then { _cityRadA = _cityRadB; };

	_potentialSpawns = [_cityPos, _cityRadA] call SL_fnc_findBuildings;

	for "_i" from 0 to random (count _potentialSpawns) step 1 do {
		_enemyType = _enemyVariants call BIS_fnc_selectRandom;
		_spawnBuilding = _potentialSpawns select (random((count _potentialSpawns) - 1));
		_spawnPosition = [_spawnBuilding] call getRandomBuildingPosition;
		_unit = (createGroup east) createUnit ["B_soldier_AR_F", _spawnPosition, [], 0, "NONE"];

		//hint format["%1", _unit];

		_m = createMarker [format ["enemy%1", random 1000], _spawnPosition];
		_m setMarkerShape "ICON"; 
		_m setMarkerType "mil_dot";
		_m setMarkerColor "ColorRed";
	};
} forEach _cities;