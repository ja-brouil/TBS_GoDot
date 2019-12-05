extends "res://Scenes/Items/Item.gd"



# Called when the node enters the scene tree for the first time.
func _ready():
	# Healing Staff Stats
	uses = 30
	might = 10
	weight = 0
	hit = 100
	crit = 0
	max_range = 1
	min_range = 1
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.HEALING
	
	# Type
	weapon_type = Item.WEAPON_TYPE.HEALING
	
	# Class
	item_class = ITEM_CLASS.MAGIC
	
	# Icon
	icon = preload("res://assets/items/staves/heal.png")
	
	# Description and name
	item_name = "Heal"
	item_description = "Restores HP to an adjacent ally."
	
	# Animation String name
	weapon_string_name = "staff"


# Special ability -> Modify this later
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 1

# Sounds
func draw_attack_sound():
	BattlefieldInfo.weapon_sounds.get_node("Draw Weapon").play(0)

func put_away_attack_sound():
	BattlefieldInfo.weapon_sounds.get_node("Put Away Weapon").play(0)
