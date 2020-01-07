extends Battlefield_Unit

func _ready():
	# Initial Animation
	$Animation.current_animation = "Idle"
	
	# Set this when the level loads but for now, this is just a test to simply things
	UnitStats.name = "Vanessa"
	UnitStats.pegasus = true
	
	# Unit Portrait
	unit_portrait_path = preload("res://assets/units/pegasus knight/Vanessa Portrait.png")
	
	# Unit Mugshot
	unit_mugshot = unit_portrait_path
	
	# Additional Movement
	UnitMovementStats.ruinsPenalty = -2
	UnitMovementStats.buildingPenalty = -99
	
	# Lance
	UnitInventory.usable_weapons.append(Item.WEAPON_TYPE.LANCE)
	var lance = preload("res://Scenes/Items/Lance/Iron Lance.tscn").instance()
	UnitInventory.add_item(lance)
	
	# Set combat node
	combat_node = preload("res://Scenes/Units/Player_Units/AllyUnits/Ally Pegasus Knight/Vanessa Combat.tscn")
	
	# Death sentence
	death_sentence = []
	death_sentence.append("Vanessa:\n\nFather, I beg you... Instead of me...help Mother...")
