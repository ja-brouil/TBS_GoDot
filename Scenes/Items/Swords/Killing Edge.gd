extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Iron Sword stats
	uses = 30
	max_uses = 30
	might = 9
	weight = 7
	hit = 70
	crit = 30
	max_range = 1
	min_range = 1
	worth = 1300
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.AXE
	
	# Icon
	icon = preload("res://assets/items/swords/killing_edge_icon.png")
	
	# Description and name
	item_name = "Killing Edge"
	item_description = "A blade used by the Assassin's Guild."
	
	# String name
	weapon_string_name = "sword"

# Sounds
func draw_attack_sound():
	BattlefieldInfo.weapon_sounds.get_node("Draw Weapon").play(0)

func put_away_attack_sound():
	BattlefieldInfo.weapon_sounds.get_node("Put Away Weapon").play(0)

# Special ability -> Modify this later
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 1
