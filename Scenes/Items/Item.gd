extends Node2D
class_name Item
# Represents an item in the game

# Item type
enum WEAPON_TYPE {WEAPON, MAGIC, CONSUMABLE}
var weapon_type = WEAPON_TYPE.WEAPON

# Weapon classes
enum WEAPON_CLASS {SWORD, AXE, SPEAR, BOW}
var weapon_class = WEAPON_CLASS.SWORD

# Magic classes
enum MAGIC_CLASS {LIGHT, DARK, ELEMENTAL}
var magic_class = MAGIC_CLASS.LIGHT

# Item Stats
var uses      # Remaining times this can be used
var might     # Damage effectivness
var weight    # Affects chance to dodge
var hit       # Base chance to hit
var crit      # Base chance to crit
var max_range # Max range
var min_range # Min range

# Description
var item_description

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.