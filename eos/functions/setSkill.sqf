_grp=(_this select 0);
_skillArray=(_this select 1);					

_skillset = server getVariable _skillArray;

{
	_unit = _x;

	{
		_skillvalue = (_skillset select _forEachIndex) + (random 0.2) - (random 0.2);
		_unit setSkill [_x, _skillvalue];
	} forEach ['aimingAccuracy', 'aimingShake', 'aimingSpeed', 'spotDistance', 'spotTime', 'courage', 'reloadSpeed', 'commanding', 'general'];

	//if (debugMode) then { hint format["adding listener to %1", name _unit]; };

	_handle = _unit execVM "scripts\insurgency\modules\ai\deathListener.sqf";
} forEach (units _grp); 