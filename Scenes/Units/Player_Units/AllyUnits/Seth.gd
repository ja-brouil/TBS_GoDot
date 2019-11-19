extends Battlefield_Unit

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set these later when the level loads
	UnitMovementStats.movementSteps = 20
	$Animation.current_animation = "Idle"
	
	# Unit portrait
	unit_portrait_path = preload("res://assets/units/cavalier/sethPortrait.png")
	
	# Weapon Select Portrait
	unit_mugshot = preload("res://assets/units/cavalier/seth mugshot.png")
	
	# Add Steel sword
	UnitInventory.add_item(preload("res://Scenes/Items/Swords/Steel Sword.tscn").instance())