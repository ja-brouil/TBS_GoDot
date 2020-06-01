extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Iron Axe stats
	uses = 45
	max_uses = 45
	might = 20
	weight = 15
	hit = 85
	crit = 30
	max_range = 2
	min_range = 1
	worth = 100
	
	# Set type
	weapon_type = Item.WEAPON_TYPE.AXE
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.LANCE
	
	# Icon
	icon = preload("res://assets/items/axes/gorehowl.png")
	
	# Description and name
	item_name = "Gorehowl"
	item_description = "Vezarius' Axe. It said that this axe contains the screams of it's victims giving it its name."
	
	# Animation Weapon
	weapon_string_name = "axe"

func draw_attack_sound():
	BattlefieldInfo.weapon_sounds.get_node("Draw Weapon").play(0)

func put_away_attack_sound():
	BattlefieldInfo.weapon_sounds.get_node("Put Away Weapon").play(0)

# Special ability -> Modify this later
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 1
