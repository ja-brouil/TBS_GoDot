extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Iron Axe stats
	uses = 45
	might = 8
	weight = 10
	hit = 75
	crit = 0
	max_range = 1
	min_range = 1
	
	# Set type
	weapon_type = Item.WEAPON_TYPE.AXE
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.LANCE
	
	# Icon
	icon = preload("res://assets/items/axes/ironAxe.png")
	
	# Description and name
	item_name = "Iron Axe"
	item_description = "A simple axe made of iron."

func draw_attack_sound():
	# Parent Override
	.draw_attack_sound()
	BattlefieldInfo.weapon_sounds.get_node("Draw Weapon").play(0)

func put_away_attack_sound():
	.put_away_attack_sound()
	BattlefieldInfo.weapon_sounds.get_node("Put Away Weapon").play(0)

# Special ability -> Modify this later
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 1