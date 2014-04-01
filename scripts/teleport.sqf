/* ----------------------------------------------------------------------------------------------------
File: teleport.sqf
Author: dolan
    
Description:
teleports to vehicles
    
Parameter(s):
(_this select 3) select 0: player 
(_this select 3) select 1: destination
---------------------------------------------------------------------------------------------------- */

_player = (_this select 3) select 0;
_dest = (_this select 3) select 1;

if (alive _dest) then { 
	_player setPos (getPos _dest);
	if (count crew _dest == 0) then { _player moveInDriver _dest; } else { _player moveInCargo _dest; };

	{ _x moveInCargo _dest; } forEach units group _player; // move all in group with you
} else {
	hintSilent format["%1 currently not available", vehicleVarName _dest];
};