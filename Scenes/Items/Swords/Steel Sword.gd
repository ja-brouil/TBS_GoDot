extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Steel Sword stats
	uses = 30
	might = 8
	weight = 10
	hit = 75
	crit = 0
	max_range = 1
	min_range = 1
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.AXE
	
	# Icon
	icon = preload("res://assets/items/swords/steel_Sword.png")
	
	# Description and name
	item_name = "Steel Sword"
	item_description = "A solid sword made of steel."

# Special ability -> Modify this later
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 1