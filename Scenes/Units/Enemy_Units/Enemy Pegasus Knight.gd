extends Battlefield_Unit

func _ready():
	# Initial Animation
	$Animation.current_animation = "Idle"
	
	# Set this when the level loads but for now, this is just a test to simply things
	UnitStats.name = "Soldier"
	UnitStats.pegasus = true
	
	# Movement
	UnitMovementStats.defaultPenalty = 0
	UnitMovementStats.forestPenalty = -1
	UnitMovementStats.fortressPenalty = -1
	UnitMovementStats.hillPenalty = -2
	UnitMovementStats.riverPenalty = 0
	UnitMovementStats.seaPenalty = -99
	UnitMovementStats.mountainPenalty = -99
	UnitMovementStats.ruinsPenalty = -2
	
	# Unit Portrait
	unit_portrait_path = preload("res://assets/units/enemyPortrait/red soldier portrait.png")
	
	# Unit Mugshot
	unit_mugshot = unit_portrait_path
	
	# Lance
	UnitInventory.usable_weapons.append(Item.WEAPON_TYPE.LANCE)
	var lance = preload("res://Scenes/Items/Lance/Iron Lance.tscn").instance()
	UnitInventory.add_item(lance)
	
	# Set combat node
	combat_node = preload("res://Scenes/Units/Enemy_Units/Black Soldier Combat.tscn")
