extends Battlefield_Unit

func _ready():
	# Initial Animation
	$Animation.current_animation = "Idle"
	
	# Set this when the level loads but for now, this is just a test to simply things
	UnitStats.name = "Ephraim Soldier"
	
	# Unit Portrait
	unit_portrait_path = preload("res://assets/units/soldier/soldier_blue_portrait.png")
	
	# Unit Mugshot
	unit_mugshot = preload("res://assets/units/soldier/soldier_blue_portrait.png")
	
	# Lance
	UnitInventory.usable_weapons.append(Item.WEAPON_TYPE.LANCE)
	var lance = preload("res://Scenes/Items/Lance/Iron Lance.tscn").instance()
	UnitInventory.add_item(lance)
	
	# Set combat node
	combat_node = preload("res://Scenes/Units/Player_Units/AllyUnits/Ephraim Soldier/Soldier Ally Combat.tscn")