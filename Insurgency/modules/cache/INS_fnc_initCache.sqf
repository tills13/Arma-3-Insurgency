if (isServer || isDedicated) then {
    INS_marker_array = [];
    INS_west_score = 0;
    
	publicVariable "INS_marker_array";
	publicVariable "INS_west_score";
	
	call INS_fnc_generateNewCache;
};