if (isServer || isDedicated) then {
	private ["_markers","_x","_randomMarker","_dist","_pos","_m","_decrease","_wait","_cacheBuildings","_targetBuilding","_cachePosition"];
	
    INS_marker_array = [];
	publicVariable "INS_marker_array";
	INS_west_score = 0;
	publicVariable "INS_west_score";
	
    INS_fncache = {
        if (typeName _this == "ARRAY") then {
			cache = _this select 0;
            cache spawn {sleep 60; deleteVehicle _this};
            _killer = _this select 1;
			
            switch (side _killer) do { // check who killed the box
                case WEST: {
					INS_west_score = INS_west_score + 1;
					publicVariable "INS_west_score";
					_this call cacheKilled;
				};
				
				case EAST: {
					INS_west_score = INS_west_score + 1;
					publicVariable "INS_west_score";
					_this call cacheKilled;
				};

				case RESISTANCE: {
					INS_west_score = INS_west_score + 1;
					publicVariable "INS_west_score";
					_this call cacheKilled;
				};

                default {
					_this call cacheFake;
				};
            };
        };
		
        if (count INS_marker_array > 0) then {
			{deleteMarker _x} forEach INS_marker_array
		};

		publicVariable "INS_marker_array";

		_cities = call SL_fnc_urbanAreas;
		_cacheTown = _cities call BIS_fnc_selectRandom;
		_cacheBuildings = _cacheTown call SO_fnc_findHouse;
		
		_targetBuilding = _cacheBuildings select (random((count _cacheBuildings) - 1)); // Pull the array and select a random building from it.
		
		_cachePosition = [_targetBuilding] call getRandomBuildingPosition; // Take the random building from the above result and pass it through gRBP function to get a single cache position
		
		// Create the cache at the random marker position
		cache = createVehicle ["Box_East_WpsSpecial_F", _cachePosition, [], 0, "None"];
		clearMagazineCargoGlobal cache;
        clearWeaponCargoGlobal cache;
		
		cache addEventHandler ["handleDamage", { 
			if ((_this select 4) == "SatchelCharge_Remote_Mag") then { 
				cache setDamage 1 
			} else {
				if ((_this select 4) == "DemoCharge_Remote_Mag") then { cache setDamage 1 } 
				else { cache setDamage 0 };
			};
		}];

        cache addMPEventHandler ["MPKilled", {_this spawn INS_fncache}];
		
		cache setPos _cachePosition;
		publicVariable "cache";

		if (INS_west_score == INS_numCaches) then {
			end_title = {titleText["All ammo caches have been destroyed!", "PLAIN"];};
			[nil, "end_title", nil, true] spawn BIS_fnc_MP;
			
			sleep 20;
			endMission "END1";
		};
		
		
		if (debugMode == 1) then {
            _m = createMarker [format ["box%1", random 1000], getposATL cache];
            _m setMarkerShape "ICON"; 
            _m setMarkerType "mil_dot";
            _m setMarkerColor "ColorRed";
		};
    };
    
    true spawn INS_fncache;
};