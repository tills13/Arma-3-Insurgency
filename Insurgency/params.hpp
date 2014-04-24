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

class TitleLineRevive { title = "Revive ---------"; values[] = {0, 0}; texts[] = {"", ""}; default = 0; };

class INS_rev_allow_revive {
	title = "		Allow Revive";
	values[] = {0, 1, 2};
	default = INS_rev_DEF_allow_revive;
	texts[] = {"Everyone", "Medic only", "Pre-Defined"};
};

class INS_rev_respawn_delay {
    title = "		Player Respawn Delay";
	values[] = {5, 30, 60, 120, 240};
    default = INS_rev_DEF_respawn_delay;
    texts[] = {"Dynamic", "30 Sec", "1 Min", "2 Min", "4 Min"};
};

class INS_rev_life_time {
    title = "		Timeout for Revive";
	values[] = {-1, 30, 60, 120, 180, 300, 600};
    default = INS_rev_DEF_life_time;
	texts[] = {"Unlimited", "30 Sec", "1 Min", "2 Min", "3 Min", "5 Min", "10 Min"};
};

class INS_rev_revive_take_time {
    title = "		Revive Action Time";
	values[] = {10, 15, 20, 25, 30, 40, 50, 60, 120};
    default = INS_rev_DEF_revive_take_time;
	texts[] = {"10 sec", "15 sec", "20 Sec", "25 Sec", "30 Sec", "40 Sec", "50 Sec", "1 Min", "2 Min"};
};

class INS_rev_require_medkit {
	title = "		Require MedKit for Revive";
	values[] = {1, 0};
	default = INS_rev_DEF_require_medkit;
	texts[] = {"Enabled", "Disabled"};
};

class INS_rev_respawn_type {
	title = "		Respawn Faction";
	values[] = {0, 1, 2};
	default = INS_rev_DEF_respawn_type;
	texts[] = {"ALL (Co-Op Only)", "SIDE (Co-Op, PvP)", "GROUP (Co-Op, PvP)"};
};

class INS_rev_respawn_location {
	title = "		Respawn Location";
	values[] = {0, 1, 2};
	default = INS_rev_DEF_respawn_location;
	texts[] = {"Base or Friendly Unit", "Base", "Friendly Unit"};
};

class INS_rev_displayRespawnLocationMarker {
	title = "		Display Respawn Location Marker";
	values[] ={1, 0};
	default = INS_rev_DEF_displayRespawnLocationMarker;
	texts[] = {"Enabled", "Disabled"};
};

class INS_rev_respawnLocationMarkerColor {
	title = "		Marker Color";
	values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
	default = INS_rev_DEF_respawnLocationMarkerColor;
	texts[] = {"ColorOrange", "ColorYellow", "ColorGreen", "ColorPink", "ColorBrown", "ColorKhaki", "ColorBlue", "ColorRed", "ColorBlack", "ColorWhite"};
};

class INS_rev_respawnLocationMarkerType {
	title = "		Marker Type";
	values[] = {0, 1, 2, 3, 4, 5, 6};
	default = INS_rev_DEF_respawnLocationMarkerType;
	texts[] = {"mil_marker", "mil_flag", "mil_dot", "mil_box", "mil_triangle", "mil_destroy", "mil_circle"};
};

class INS_rev_jip_action {
	title = "		Join in Progress Action";
	values[] = {0, 1, 2};
	default = INS_rev_DEF_jip_action;
	texts[] = {"None", "Teleport Action", "Standard Respawn Menu"};
};

class INS_rev_can_drag_body {
	title = "		Body Dragging";
	values[] = {1, 0};
	default = INS_rev_DEF_can_drag_body;
	texts[] = {"Enabled", "Disabled"};
};

class INS_rev_can_carry_body {
	title = "		Body Carrying";
	values[] = {1, 0};
	default = INS_rev_DEF_can_carry_body;
	texts[] = {"Enabled", "Disabled"};
};

class INS_rev_medevac {
	title = "		MEDEVAC";
	values[] = {1, 0};
	default = INS_rev_DEF_medevac;
	texts[] = {"Enabled", "Disabled"};
};

class INS_rev_near_friendly {
	title = "		Cannot Respawn Near Friendlies (except at base)";
	values[] = {1, 0};
	default = INS_rev_DEF_near_friendly;
	texts[] = {"Enabled", "Disabled"};
};

class INS_rev_near_friendly_distance {
	title = "		Friendly Unit Search Distance (in meters)";
	values[] = {10, 30, 50, 100, 300, 500};
	default = INS_rev_DEF_near_friendly_distance;
};

class INS_rev_near_enemy {
	title = "		Cannot Respawn Near Enemies (except at base)";
	values[] = {1, 0};
	default = INS_rev_DEF_near_enemy;
	texts[] = {"Enabled", "Disabled"};
};

class INS_rev_near_enemy_distance {
	title = "		Enemy Unit Search Distance (in meters)";
	values[] = {10, 30, 50, 100, 300, 500};
	default = INS_rev_DEF_near_enemy_distance;
};

class INS_rev_all_dead_respawn {
	title = "		Respawn Immediately if all Players Dead";
	values[] = {1, 0};
	default = INS_rev_DEF_all_dead_respawn;
	texts[] = {"Enabled", "Disabled"};
};