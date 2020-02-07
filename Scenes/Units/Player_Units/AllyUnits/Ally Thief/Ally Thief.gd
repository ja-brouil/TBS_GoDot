extends Battlefield_Unit

func _ready():
	# Initial Animation
	$Animation.current_animation = "Idle"
	
	# Set this when the level loads but for now, this is just a test to simply things
	UnitStats.name = "Colm"
	
	# Unit Portrait
	unit_portrait_path = preload("res://assets/units/thief/colm portrait.png")
	
	# Unit Mugshot
	unit_mugshot = unit_portrait_path
	
	# Weapons and Inventory
	UnitInventory.usable_weapons.append(Item.WEAPON_TYPE.SWORD)
	UnitInventory.add_item(preload("res://Scenes/Items/Swords/Iron Sword.tscn").instance())
	UnitInventory.add_item(preload("res://Scenes/Items/Swords/Killing Edge.tscn").instance())
	
	# Set combat node
	combat_node = preload("res://Scenes/Units/Player_Units/AllyUnits/Ally Thief/Colm Combat.tscn")
	
	# Death sentence
	death_sentence = []
	death_sentence.append("Colm:\n\nLooks like my thieving days have come to an end...")
