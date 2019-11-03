extends Battlefield_Unit

# Called when the node enters the scene tree for the first time.
func _ready():
	UnitMovementStats.movementSteps = 15
	$Animation.current_animation = "Idle"