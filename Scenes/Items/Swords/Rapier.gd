extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Steel Sword stats
	uses = 40
	might = 7
	weight = 5
	hit = 95
	crit = 10
	max_range = 1
	min_range = 1
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.AXE
	
	# Icon
	icon = preload("res://assets/items/swords/rapier.png")
	
	# Description and name
	item_name = "Rapier"
	item_description = "A flexible sword with a higher crit chance."
	
	# Sounds

# Special ability -> Modify this later
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 1