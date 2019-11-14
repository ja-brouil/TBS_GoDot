extends Battlefield_Unit

# Specific Unit Constants

func _ready():
	# Initial Animation
	$Animation.current_animation = "Idle"
	
	# Set this when the level loads but for now, this is just a test to simply things
	UnitStats.name = "Eirika"
	UnitStats.current_health = 14
	
	# Unit Portrait
	unit_portrait_path = preload("res://assets/units/eirika/eirikaPortrait.png")