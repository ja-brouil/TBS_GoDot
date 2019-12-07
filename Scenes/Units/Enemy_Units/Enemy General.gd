extends Battlefield_Unit

# Called when the node enters the scene tree for the first time.
func _ready():
	$Animation.current_animation = "Idle"
	UnitMovementStats.is_ally = false
	
	# Portrait
	unit_portrait_path = preload("res://assets/units/enemyPortrait/Main Villain MugShot.png")
	
	# Mug shot
	unit_mugshot = preload("res://assets/units/enemyPortrait/Main Villain MugShot.png")
	
	# Add axe
	var axe = preload("res://Scenes/Items/Axes/Iron Axe.tscn").instance()
	UnitInventory.add_item(axe)
	
	# Combat sprite
	combat_node = preload("res://Scenes/Units/Enemy_Units/Bandit Combat.tscn")