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
var max_uses  # Max amount of uses
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

# Cost 
var worth = 100

# Animation String
var weapon_string_name

# Usability by current unit/class
var is_usable_by_current_unit = false

# Sound effects
func draw_attack_sound():
	pass

func put_away_attack_sound():
	pass

func use_consumable():
	pass

# Get the selling cost
func get_selling_cost() -> int:
	var selling_worth = int((worth * 0.85) *  (uses / max_uses))
	if selling_worth == 0:
		return 1
	return selling_worth

## Debug functions ##
func get_stats_stringify():
	return str("Name: ", item_name,"\n",
		"Uses: ", uses,"\n",
		"Might: ", might, "\n",
		"Weight: ", weight, "\n",
		"Hit: ", hit, "\n",
		"Crit: ", crit, "\n",
		"Min Range: ", min_range, "\n",
		"Max Range: ", max_range, "\n",
		"Value: ", str(get_selling_cost()), "\n",
		"Item Desc: ", item_description, "\n"
		)

func print_stats():
	print(
		"Name: ", item_name,"\n",
		"Uses: ", uses,"\n",
		"Might: ", might, "\n",
		"Weight: ", weight, "\n",
		"Hit: ", hit, "\n",
		"Crit: ", crit, "\n",
		"Min Range: ", min_range, "\n",
		"Max Range: ", max_range, "\n",
		"Item Desc: ", item_description, "\n"
	)

# Special abilities should be added here in the extended item slot
func save():
	var save_dict = {
		# Node info
		"filename" : get_filename(),
		"parent": get_parent().get_path(),
		
		# Item stats
		"item_stats": {
			"uses" : uses,
			"max_uses": max_uses,
			"might" : might,
			"weight" : weight,
			"hit" : hit,
			"crit" : crit,
			"max_range" : max_range,
			"min_range" : min_range,
			"item_description": item_description,
			"item_name": item_name,
			"worth": worth
		}
	}
	return save_dict

func load_item(stat_data):
	for key in stat_data.keys():
		if key == "item_description" || key == "item_name":
			set(key, stat_data[key])
		else:
			set(key, int(stat_data[key]))
