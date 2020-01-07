extends Battlefield_Unit

func _ready():
	# Initial Animation
	$Animation.current_animation = "Idle"
	
	# Set this when the level loads but for now, this is just a test to simply things
	UnitStats.name = "Eirika"
	
	# Unit Portrait
	unit_portrait_path = preload("res://assets/units/eirika/eirika mugshot.png")
	
	# Unit Mugshot
	unit_mugshot = preload("res://assets/units/eirika/eirika mugshot.png")
	
	# Weapons and Inventory
	UnitInventory.usable_weapons.append(Item.WEAPON_TYPE.SWORD)
	UnitInventory.add_item(preload("res://Scenes/Items/Swords/Iron Sword.tscn").instance())
	UnitInventory.add_item(preload("res://Scenes/Items/Swords/Rapier.tscn").instance())
	
	# Set combat node
	combat_node = preload("res://Scenes/Units/Player_Units/AllyUnits/Eirika/Eirika Combat.tscn")
	
	# Death sentence
	death_sentence = []
	death_sentence.append("Eirika:\n\nFather, everyone... I've failed you all... I'm sorry everyone...")
