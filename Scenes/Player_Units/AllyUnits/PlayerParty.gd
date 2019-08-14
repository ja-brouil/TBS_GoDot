extends Node2D

# Controls who is currently in the party of the player

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up Eirika
	$"Eirika".UnitMovementStats.movementSteps = 5
	
	# Set up Seth
	$"Seth".UnitMovementStats.movementSteps = 8