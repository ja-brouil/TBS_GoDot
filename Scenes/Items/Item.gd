extends Node2D
class_name Item
# Represents an item in the game

# Item type
enum WEAPON_TYPE {SWORD, AXE, LANCE, BOW, LIGHT, DARK, ELEMENTAL, HEALING, NO_WEAKNESS}
var weapon_type = WEAPON_TYPE.SWORD
enum ITEM_CLASS {PHYSICAL, MAGIC, CONSUMABLE}
var item_class =  ITEM_CLASS.PHYSICAL

# Strong against and weak against
var strong_against

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
var item_name

# Icon
var icon

# Animation String
var weapon_string_name

# Usability by current unit/class
var is_usable_by_current_unit = false

# Sound effects
func draw_attack_sound():
	pass

func put_away_attack_sound():
	pass

# Consumable functions
func can_be_consumed():
	return true

func use_consumable():
	pass

# Special abilities should be added here in the extended item slot
