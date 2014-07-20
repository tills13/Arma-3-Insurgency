/* task_master.sqf
 * manages tasks throughout the mission. tasks are side-missions 
 * that aren't necessarily required to complete the main-mission
 *
 * depends on file "task_functions.sqf"
 * null = [] execVM "task_master.sqf"
 */

dl_fnc_exec_task = {
		
};


if (isServer) { // only executed on the server
	_task_descriptions = ["search for and rescue captured %1 in %2", // soldiers,civilians,scientists,etc 
				   		  "search and destroy a %1 in %2", // cache,car,tank,helo,etc
				   		  "kill general %1. he was last spotted in %2", // names... racist?
				   		  "search the wreckage of a downed helo for survivors. destroy any intel you find. the helo was last seen near %1.",
				   		  ""];

	_task_area = (call SL_fnc_urbanAreas) call BIS_fnc_selectRandom;
	_task_location_name = _task_area select 1;
	_task_location = _task_area select 2;
	_task_location_radius = (_task_area select 3) max (_task_area select 4);

	//_task_markers = [_task_location, _task_location_radius] call dl_fnc_getMarkersForPosition;
	_task_type = floor random (count _task_descriptions);
	[, ] call dl_fnc_exec_task;

} else { // updated JIP clients with current task info
	
}