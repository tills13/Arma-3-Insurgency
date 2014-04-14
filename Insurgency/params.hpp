#include "config.hpp"

class INS_PARAM_numCaches {
	title = "Total number of caches";
	values[] = {2, 4, 6, 8, 10, 12, 14, 16};
	texts[] = {"Two", "Four", "Six", "Eight", "Ten", "Twelve", "Fourteen", "Sixteen"};
	default = INS_DEF_numCaches;
};

class INS_PARAM_intelItems {
	title = "Number of static intel items (per town)";
	values[] = {1, 2, 3, 4, 5, 6, 7, 8};
	texts[] = {"One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight"};
	default = INS_DEF_intelItems;
};

class INS_PARAM_probOfDrop {
	title = "Probability of intel drop (in % of kills)";
	values[] = {5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90};
	default = INS_DEF_probOfDrop;
};

class INS_PARAM_intelTimeout {
	title = "Time until dropped intel items disappear (in seconds)";
	values[] = {60, 120, 180, 240, 300, 360};
	default = INS_DEF_intelTimeout;
};