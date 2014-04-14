//ARMA3Alpha function LV_fnc_getPlayers v1.0 - by SPUn / lostvar
//Returns array of all alive non-captive players
private["_all","_players"];
_players = [];

while{(count _players) == 0} do {
	{
		if (isPlayer _x) then {
			if((alive _x) && (!captive _x)) then {
				_players = _players + [_x];
			};
		};
	} forEach playableUnits;
	sleep 3;
};

_players
