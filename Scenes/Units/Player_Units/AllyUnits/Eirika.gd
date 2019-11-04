extends Battlefield_Unit

func _ready():
	$Animation.current_animation = "Idle"
	
	# Set this when the level loads but for now, this is just a test to simply things
	UnitStats.name = "Eirika"