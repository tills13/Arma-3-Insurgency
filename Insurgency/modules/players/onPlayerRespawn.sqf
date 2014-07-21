/* ----------------------------------------------------------------------------------------------------
File: onPlayerRespawn.sqf
Author: dolan
    
Description: reapplies player's previous inventory after respawning. No longer using VAS so this is required
---------------------------------------------------------------------------------------------------- */

_unit = _this select 0;
_corpse = _this select 1;

//Strip the unit down
removeAllWeapons _unit;
{ _unit removeMagazine _x; } forEach (magazines _unit);

removeUniform _unit;
removeVest _unit;
removeBackpack _unit;
removeGoggles _unit;
removeHeadGear _unit;
removeWeapon _unit;
removeMagazines _unit;
{ _unit unassignItem _x; _unit removeItem _x; } forEach (assignedItems _unit);

// appearance + items
_unit addHeadgear headgear _corpse;
_unit addGoggles goggles _corpse;
_unit addUniform uniform _corpse;
_unit addVest vest _corpse;
_unit addBackpack backpack _corpse;

// inventory and weapons
{ _unit addItemToBackpack _x } forEach backpackItems _corpse; // backpack
{ _unit addItemToVest _x } forEach vestItems _corpse; // vest
{ _unit addItemToUniform _x } forEach uniformItems _corpse; // uniform

// not sure if I need this block
{ _unit LinkItem _x; } forEach (assignedItems _corpse);
{ _unit addMagazine _x; } forEach (magazines _corpse);
{ _unit addWeapon _x; } forEach (weapons _corpse);

//load the guns
_unit addPrimaryWeaponItem (primaryWeaponMagazine _corpse);
_unit addPrimaryWeaponItem (primaryWeaponMagazine _corpse);
_unit addPrimaryWeaponItem (primaryWeaponMagazine _corpse);

// weapon accessories
{ _unit addPrimaryWeaponItem _x } forEach _corpse weaponAccessories (primaryWeapon _corpse); // primary weapon attachments
{ _unit addSecondaryWeaponItem _x } forEach _corpse weaponAccessories (secondaryWeapon _corpse); // secondary weapon attachments
{ _unit addHandgunItem _x } forEach _corpse weaponAccessories (handgunWeapon _corpse); // sidearm weapon attachments