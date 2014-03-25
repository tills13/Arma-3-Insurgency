/* ----------------------------------------------------------------------------------------------------
File: recruitAI.sqf
Author: dolan
    
Description:
recruits AI to _player's group
    
Parameter(s):
(_this select 3) select 0: player
(_this select 3) select 1: type
---------------------------------------------------------------------------------------------------- */

_player = (_this select 3) select 0;
_type = (_this select 3) select 1;

_type createUnit [position _player, group _player];