#include "config.hpp"

class casPlayerTimeout {
	title = "	Time in between player CAS requests (seconds)";
	values[] = {10, 20, 30, 40, 50, 60, 70, 80};
	default = CAS_DEF_casPlayerTimeout;
};

class casPlayerTimeLimit {
	title = "	Time in available to player controlled CAS (in seconds)";
	values[] = {30, 60, 90, 120, 150, 180, 210, 240};
	default = CAS_DEF_casPlayerTimeLimit;
};

class casAITimeout {
	title = "	Time in between AI CAS requests (in seconds)";
	values[] = {10, 20, 30, 40, 50, 60, 70, 80};
	default = CAS_DEF_casAITimeout;
};