#include "config.hpp"

class TitleLine {
	title = "INS_Revive";
	values[] = {0, 0};
	texts[] = {"", ""};
	default = 0;
};

class INS_REV_PARAM_allow_revive {
	title = "Allow Revive";
	values[] = {0, 1, 2};
	default = INS_REV_DEF_allow_revive;
	texts[] = {"Everyone", "Medic only", "Pre-Defined"};
};

class INS_REV_PARAM_respawn_delay {
    title = "Player Respawn Delay";
	values[] = {5, 30, 60, 120, 240};
    default = INS_REV_DEF_respawn_delay;
    texts[] = {"Dynamic", "30 Sec", "1 Min", "2 Min", "4 Min"};
};

class INS_REV_PARAM_life_time {
    title = "Timeout for Revive";
	values[] = {-1, 30, 60, 120, 180, 300, 600};
    default = INS_REV_DEF_life_time;
	texts[] = {"Unlimited", "30 Sec", "1 Min", "2 Min", "3 Min", "5 Min", "10 Min"};
};

class INS_REV_PARAM_revive_take_time {
    title = "Revive Action Time";
	values[] = {10, 15, 20, 25, 30, 40, 50, 60, 120};
    default = INS_REV_DEF_revive_take_time;
	texts[] = {"10 sec", "15 sec", "20 Sec", "25 Sec", "30 Sec", "40 Sec", "50 Sec", "1 Min", "2 Min"};
};

class INS_REV_PARAM_require_medkit {
	title = "Require MedKit for Revive";
	values[] = {1, 0};
	default = INS_REV_DEF_require_medkit;
	texts[] = {"Enabled", "Disabled"};
};

class INS_REV_PARAM_respawn_type {
	title = "Respawn Faction";
	values[] = {0, 1, 2};
	default = INS_REV_DEF_respawn_type;
	texts[] = {"ALL (Co-Op Only)", "SIDE (Co-Op, PvP)", "GROUP (Co-Op, PvP)"};
};

class INS_REV_PARAM_respawn_location {
	title = "Respawn Location";
	values[] = {0, 1, 2};
	default = INS_REV_DEF_respawn_location;
	texts[] = {"Base or Friendly Unit", "Base", "Friendly Unit"};
};

class INS_REV_PARAM_displayRespawnLocationMarker {
	title = "Display Respawn Location Marker";
	values[] ={1, 0};
	default = INS_REV_DEF_displayRespawnLocationMarker;
	texts[] = {"Enabled", "Disabled"};
};

class INS_REV_PARAM_respawnLocationMarkerColor {
	title = "Marker Color";
	values[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
	default = INS_REV_DEF_respawnLocationMarkerColor;
	texts[] = {"ColorOrange", "ColorYellow", "ColorGreen", "ColorPink", "ColorBrown", "ColorKhaki", "ColorBlue", "ColorRed", "ColorBlack", "ColorWhite"};
};

class INS_REV_PARAM_respawnLocationMarkerType {
	title = "Marker Type";
	values[] = {0, 1, 2, 3, 4, 5, 6};
	default = INS_REV_DEF_respawnLocationMarkerType;
	texts[] = {"mil_marker", "mil_flag", "mil_dot", "mil_box", "mil_triangle", "mil_destroy", "mil_circle"};
};

class INS_REV_PARAM_jip_action {
	title = "Join in Progress Action";
	values[] = {0, 1, 2};
	default = INS_REV_DEF_jip_action;
	texts[] = {"None", "Teleport Action", "Standard Respawn Menu"};
};

class INS_REV_PARAM_can_drag_body {
	title = "Body Dragging";
	values[] = {1, 0};
	default = INS_REV_DEF_can_drag_body;
	texts[] = {"Enabled", "Disabled"};
};

class INS_REV_PARAM_can_carry_body {
	title = "Body Carrying";
	values[] = {1, 0};
	default = INS_REV_DEF_can_carry_body;
	texts[] = {"Enabled", "Disabled"};
};

class INS_REV_PARAM_medevac {
	title = "MEDEVAC";
	values[] = {1, 0};
	default = INS_REV_DEF_medevac;
	texts[] = {"Enabled", "Disabled"};
};

class INS_REV_PARAM_can_respawn_player_body {
	title = "Respawn on Body";
	values[] = {1, 0};
	default = INS_REV_DEF_can_respawn_player_body;
	texts[] = {"Enabled", "Disabled"};
};

class INS_REV_PARAM_half_dead_repsawn_player_body {
	title = "Respawn on Body  (50% of friendlies are dead)";
	values[] = {1, 0};
	default = INS_REV_DEF_half_dead_repsawn_player_body;
	texts[] = {"Enabled", "Disabled"};
};

class INS_REV_PARAM_near_friendly {
	title = "Cannot Respawn Near Friendlies (except at base)";
	values[] = {1, 0};
	default = INS_REV_DEF_near_friendly;
	texts[] = {"Enabled", "Disabled"};
};

class INS_REV_PARAM_near_friendly_distance {
	title = "Friendly Unit Search Distance (in meters)";
	values[] = {10, 30, 50, 100, 300, 500};
	default = INS_REV_DEF_near_friendly_distance;
};

class INS_REV_PARAM_near_enemy {
	title = "Cannot Respawn Near Enemies (except at base)";
	values[] = {1, 0};
	default = INS_REV_DEF_near_enemy;
	texts[] = {"Enabled", "Disabled"};
};

class INS_REV_PARAM_near_enemy_distance {
	title = "Enemy Unit Search Distance (in meters)";
	values[] = {10, 30, 50, 100, 300, 500};
	default = INS_REV_DEF_near_enemy_distance;
};

class INS_REV_PARAM_all_dead_respawn {
	title = "Respawn Immediately if all Players Dead";
	values[] = {1, 0};
	default = INS_REV_DEF_all_dead_respawn;
	texts[] = {"Enabled", "Disabled"};
};

class INS_REV_PARAM_loadout_on_respawn {
	title = "Restore Loadout on Respawn";
	values[] = {1, 0};
	default = INS_REV_DEF_loadout_on_respawn;
	texts[] = {"Enabled", "Disabled"};
};
