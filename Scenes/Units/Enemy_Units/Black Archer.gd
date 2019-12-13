extends Battlefield_Unit

func _ready():
	# Initial Animation
	$Animation.current_animation = "Idle"
	
	# Unit Portrait
	unit_portrait_path = preload("res://assets/units/enemyPortrait/red soldier portrait.png")
	unit_mugshot = unit_portrait_path
	
	# Unit Mugshot
	unit_mugshot = unit_portrait_path
	
	# Weapons and Inventory
	UnitInventory.usable_weapons.append(Item.WEAPON_TYPE.BOW)
	UnitInventory.add_item(preload("res://Scenes/Items/Lance/Iron Lance.tscn").instance())
	UnitInventory.add_item(preload("res://Scenes/Items/Swords/Iron Sword.tscn").instance())
	UnitInventory.add_item(preload("res://Scenes/Items/Bows/Iron Bow.tscn").instance())
	
	# Set combat node
	combat_node = preload("res://Scenes/Units/Enemy_Units/Black Archer Combat.tscn")