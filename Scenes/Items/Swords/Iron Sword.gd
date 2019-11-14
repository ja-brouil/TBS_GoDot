extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set strong against and weak against
	strong_against = Item.WEAPON_CLASS.AXE
	weak_against = Item.WEAPON_CLASS.LANCE

# Special ability
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 1