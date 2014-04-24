[player, player] call INS_rev_fnct_onKilled;
player removeAction INS_rev_GVAR_teleportToTeam;
player setVariable ["INS_rev_PVAR_isTeleport", true, true];
