extends Battlefield_Unit

# Called when the node enters the scene tree for the first time.
func _ready():
	$Animation.current_animation = "Idle"
	UnitMovementStats.is_ally = false
	
	# Portrait
	unit_portrait_path = preload("res://assets/units/enemyPortrait/red soldier portrait.png")
	
	# Mug shot
	unit_mugshot = preload("res://assets/units/enemyPortrait/red soldier portrait.png")
	
	# Add Lance
	UnitInventory.usable_weapons.append(Item.WEAPON_TYPE.LANCE)
	var lance = preload("res://Scenes/Items/Lance/Iron Lance.tscn").instance()
	UnitInventory.add_item(lance)
	
	# Combat sprite
	combat_node = preload("res://Scenes/Units/Enemy_Units/Black Soldier Combat.tscn")
