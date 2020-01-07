extends Battlefield_Unit

func _ready():
	# Initial Animation
	$Animation.current_animation = "Idle"
	
	UnitStats.name = "Ewan"
	
	# Unit Portrait
	unit_portrait_path = preload("res://assets/units/mage/ewan portrait.png")
	
	# Unit Mugshot
	unit_mugshot = unit_portrait_path
	
	# Weapons and Inventory
	UnitInventory.usable_weapons.append(Item.WEAPON_TYPE.ELEMENTAL)
	UnitInventory.add_item(preload("res://Scenes/Items/Tomes/Fire.tscn").instance())
	
	# Set combat node
	combat_node = preload("res://Scenes/Units/Player_Units/AllyUnits/Ally Mage/Ally Mage Combat.tscn")
	
	# Death sentence
	death_sentence = []
	death_sentence.append("Ewan:\n\nEug, sorry master... I didn't study hard enough...")
