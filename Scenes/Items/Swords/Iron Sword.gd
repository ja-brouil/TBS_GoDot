extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Iron Sword stats
	uses = 46
	might = 5
	weight = 5
	hit = 1
	crit = 0
	max_range = 1
	min_range = 1
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.AXE
	
	# Icon
	icon = preload("res://assets/items/swords/iron_Sword.png")
	
	# Description and name
	item_name = "Iron Sword"
	item_description = "A simple sword made of iron."
	
	# String name
	weapon_string_name = "sword"

# Sounds
func draw_attack_sound():
	BattlefieldInfo.weapon_sounds.get_node("Draw Weapon").play(0)

func put_away_attack_sound():
	BattlefieldInfo.weapon_sounds.get_node("Put Away Weapon").play(0)

# Special ability -> Modify this later
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 1