extends Battlefield_Unit

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set these later when the level loads
	UnitMovementStats.movementSteps = 8
	$Animation.current_animation = "Idle"
	
	# Unit portrait
	unit_portrait_path = preload("res://assets/units/cavalier/sethPortrait.png")