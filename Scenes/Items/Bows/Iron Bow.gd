extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Steel Sword stats
	uses = 45
	max_uses = 45
	might = 6
	weight = 5
	hit = 85
	crit = 0
	max_range = 2
	min_range = 2
	worth = 540
	
	# Set type
	weapon_type = Item.WEAPON_TYPE.BOW
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.NO_WEAKNESS
	
	# Icon
	icon = preload("res://assets/items/bows/iron bow.png")
	
	# Description and name
	item_name = "Iron Bow"
	item_description = "A flexible bow made out of iron."
	
	# Animation String name
	weapon_string_name = "bow"


# Special ability -> Modify this later
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	# Triple damage against flying units
	if unit_that_is_being_attacked.UnitStats.pegasus:
		return 3
	else:
		return 1

# Sounds
func draw_attack_sound():
	BattlefieldInfo.weapon_sounds.get_node("Bow").play(0)

func put_away_attack_sound():
	pass
