extends "res://Scenes/Items/Item.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Iron Axe stats
	uses = 40
	max_uses = 45
	might = 5
	weight = 4
	hit = 90
	crit = 0
	max_range = 2
	min_range = 1
	worth = 300
	
	# Set type
	weapon_type = Item.WEAPON_TYPE.ELEMENTAL
	
	# Set strong against and weak against
	strong_against = Item.WEAPON_TYPE.LIGHT
	
	# Magic class
	item_class = Item.ITEM_CLASS.MAGIC
	
	# Icon
	icon = preload("res://assets/items/tomes/fire.png")
	
	# Description and name
	item_name = "Fire Tome"
	item_description = "A mage's basic fire tome to burn their enemies."
	
	# Animation Weapon
	weapon_string_name = "fire"

func draw_attack_sound():
	pass

func put_away_attack_sound():
	pass

# Special ability -> Modify this later
func special_ability(unit_holding_this_item, unit_that_is_being_attacked):
	return 1
