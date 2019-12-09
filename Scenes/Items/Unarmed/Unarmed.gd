extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Steel Sword stats
	uses = 9999999
	might = 0
	weight = 0
	hit = 0
	crit = 0
	max_range = 0
	min_range = 0
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.AXE
	
	# Icon
	icon = preload("res://assets/items/Unarmed/Unarmed.png")
	
	# Description and name
	item_name = "Unarmed"
	item_description = "It's probably best not to fight with your hands..."
	
	# Animation String name
	weapon_string_name = "unarmed"


# Special ability -> Modify this later
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 0