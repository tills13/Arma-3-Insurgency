#include "config.hpp"

class destroyedRespawnDelay {
	title = "Time until destroyed vehicles respawn (in seconds)";
	values[] = {0, 10, 20, 30, 40, 50, 60, 70, 80};
	default = INS_DEF_destroyedRespawnDelay;
};

class abandonedRespawnDelay {
	title = "Time until abandoned vehicles respawn (in seconds)";
	values[] = {60, 70, 80, 90, 100, 120, 180, 240, 300};
	default = INS_DEF_abandonedRespawnDelay;
};

class weatherChangeRate {
	title = "Weather change rate (in minutes)";
	values[] = {5, 10, 15, 20, 25, 30, 35, 40};
	default = INS_DEF_weatherChangeRate;
};

class debugMode {
	title = "Show debug messages";
	values[] = {1, 0};
	texts[] = {"On", "Off"};
	default = INS_DEF_debugMode;
};