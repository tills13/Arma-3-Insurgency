private ["_unit","_destination","_stPos"];

_unit = _this select 0;
_destination = _this select 1;
_unit setSkill ["courage", 1.0];

while { alive _unit } do {
	_stPos = (_unit getVariable "stPos0");
	if (isNil("_stPos")) then { _unit setVariable ["stPos0", (getPos _unit), false]; } 
	else {
		if (str(_stPos) == str(getPos _unit)) then { 
			_unit setDamage 1;
		} else {
			_unit setVariable ["stPos0", (getPos _unit), false];
		};
	};

	if((_unit distance _destination) < 200) then {
		if (vehicle _unit != _unit) then { deleteVehicle (vehicle _unit); };
		deleteVehicle _unit;
	};

	sleep 25;
};