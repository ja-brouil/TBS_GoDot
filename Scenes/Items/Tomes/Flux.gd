extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Iron Axe stats
	uses = 45
	max_uses = 45
	might = 7
	weight = 8
	hit = 75
	crit = 0
	max_range = 2
	min_range = 1
	worth = 350
	
	# Set type
	weapon_type = Item.WEAPON_TYPE.DARK
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.ELEMENTAL
	
	# Magic class
	item_class = Item.ITEM_CLASS.MAGIC
	
	# Icon
	icon = preload("res://assets/items/tomes/flux.png")
	
	# Description and name
	item_name = "Flux Tome"
	item_description = "A basic tome that contains forbidden dark arts."
	
	# Animation Weapon
	weapon_string_name = "flux"

func draw_attack_sound():
	pass

func put_away_attack_sound():
	pass

# Special ability -> Modify this later
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 1
