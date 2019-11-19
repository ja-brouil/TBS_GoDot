extends Battlefield_Unit

# Called when the node enters the scene tree for the first time.
func _ready():
	$Animation.current_animation = "Idle"
	UnitMovementStats.is_ally = false
	
	# Test for UI
	UnitStats.current_health = randi() % 19 + 1
	
	# Portrait
	unit_portrait_path = preload("res://assets/units/enemyPortrait/normalSoldierPortrait.png")
	
	# Mug shot
	unit_mugshot = preload("res://assets/units/bandit/bandit mugshot.png")