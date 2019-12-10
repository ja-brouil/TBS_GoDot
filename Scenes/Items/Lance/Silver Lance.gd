extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Steel Sword stats
	uses = 20
	might = 14
	weight = 10
	hit = 75
	crit = 0
	max_range = 1
	min_range = 1
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.SWORD
	
	# Weapon type
	weapon_type = Item.WEAPON_TYPE.LANCE
	
	# Icon
	icon = preload("res://assets/items/lances/iron_lance_icon.png")
	
	# Description and name
	item_name = "Silver Lance"
	item_description = "A lance made of silver whose mighty blows offset its steep price."
	
	# Animation String name
	weapon_string_name = "lance"

# Special ability -> Modify this later
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 1

# Sounds
func draw_attack_sound():
	BattlefieldInfo.weapon_sounds.get_node("Draw Weapon").play(0)

func put_away_attack_sound():
	BattlefieldInfo.weapon_sounds.get_node("Put Away Weapon").play(0)
