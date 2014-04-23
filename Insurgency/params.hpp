#include "config.hpp"

class INS_numCaches {
	title = "		Total number of caches";
	values[] = {2, 4, 6, 8, 10, 12, 14, 16};
	texts[] = {"Two", "Four", "Six", "Eight", "Ten", "Twelve", "Fourteen", "Sixteen"};
	default = INS_DEF_numCaches;
};

class INS_intelItems {
	title = "		Number of static intel items (per town)";
	values[] = {1, 2, 3, 4, 5, 6, 7, 8};
	texts[] = {"One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight"};
	default = INS_DEF_intelItems;
};

class INS_probOfDrop {
	title = "		Probability of intel drop (in % of kills)";
	values[] = {5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90};
	default = INS_DEF_probOfDrop;
};

class INS_intelTimeout {
	title = "		Time until dropped intel items disappear (in seconds)";
	values[] = {60, 120, 180, 240, 300, 360};
	default = INS_DEF_intelTimeout;
};

class TitleLineCAS { title = "Close Air Support ---------"; values[] = {0, 0}; texts[] = {"", ""}; default = 0; };

class casPlayerTimeout {
	title = "		Time in between player CAS requests (seconds)";
	values[] = {10, 20, 30, 40, 50, 60, 70, 80};
	default = CAS_DEF_casPlayerTimeout;
};

class casPlayerTimeLimit {
	title = "		Time in available to player controlled CAS (in seconds)";
	values[] = {30, 60, 90, 120, 150, 180, 210, 240};
	default = CAS_DEF_casPlayerTimeLimit;
};

class casAITimeout {
	title = "		Time in between AI CAS requests (in seconds)";
	values[] = {10, 20, 30, 40, 50, 60, 70, 80};
	default = CAS_DEF_casAITimeout;
};

class casNumRequestsBLUFOR {
	title = "		Number of times BLUFOR can call CAS";
	values[] = {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
	texts[] = {"Unlimited", "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"};
	default = CAS_DEF_casNumRequestsBLUFOR;
};

class casNumRequestsOPFOR {
	title = "		Number of times OPFOR can call CAS";
	values[] = {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
	texts[] = {"Unlimited", "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"};
	default = CAS_DEF_casNumRequestsOPFOR;
};