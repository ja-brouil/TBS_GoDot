extends Node2D
class_name Item
# Represents an item in the game

# Item type
enum WEAPON_TYPE {WEAPON, MAGIC, CONSUMABLE}
var weapon_type = WEAPON_TYPE.WEAPON

# Weapon classes
enum WEAPON_CLASS {SWORD, AXE, LANCE, BOW}
var weapon_class = WEAPON_CLASS.SWORD

# Magic classes
enum MAGIC_CLASS {LIGHT, DARK, ELEMENTAL}
var magic_class = MAGIC_CLASS.LIGHT

# Strong against and weak against
var strong_against
var weak_against

# Item Stats
var uses      # Remaining times this can be used
var might     # Damage effectivness
var weight    # Affects chance to dodge and attack speed
var hit       # Base chance to hit
var crit      # Base chance to crit
var max_range # Max range
var min_range # Min range

# Description
var item_description

# Special abilities should be added here in the extended item slot