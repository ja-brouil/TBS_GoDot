extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Iron Sword stats
	uses = 46
	might = 5
	weight = 5
	hit = 90
	crit = 0
	max_range = 1
	min_range = 1
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.AXE
	weak_against = Item.WEAPON_TYPE.LANCE

# Special ability
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 1