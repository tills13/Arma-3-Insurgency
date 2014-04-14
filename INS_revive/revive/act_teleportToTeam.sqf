[player, player] call INS_REV_FNCT_onKilled;
player removeAction INS_REV_GVAR_teleportToTeam;
player setVariable ["INS_REV_PVAR_isTeleport", true, true];
