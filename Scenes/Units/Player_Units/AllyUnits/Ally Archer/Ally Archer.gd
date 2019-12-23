extends Battlefield_Unit

func _ready():
	# Initial Animation
	$Animation.current_animation = "Idle"
	
	# Unit Portrait
	unit_portrait_path = preload("res://assets/units/archer/Naomi.png")
	
	# Unit Mugshot
	unit_mugshot = unit_portrait_path
	
	# Weapons and Inventory
	UnitInventory.usable_weapons.append(Item.WEAPON_TYPE.BOW)
	UnitInventory.add_item(preload("res://Scenes/Items/Swords/Iron Sword.tscn").instance())
	UnitInventory.add_item(preload("res://Scenes/Items/Bows/Iron Bow.tscn").instance())
	
	# Set combat node
	combat_node = preload("res://Scenes/Units/Player_Units/AllyUnits/Ally Archer/Naomi Combat.tscn")
	
	# Death sentence
	death_sentence = []
	death_sentence.append("Neimi:\n\nLady Eirika... I missed the mark...")