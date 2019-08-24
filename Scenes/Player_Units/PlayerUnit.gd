# Represents all the units in the game
extends Node2D

class_name Battlefield_Unit

# Movement -> Ally status is in here
var UnitMovementStats
var animation_movement

# Unit State
var UnitActionStatus

# Unit Stats
var UnitStats

# Inventory
var UnitInventory

func _ready():
	pass
	# Movement Stats
	UnitMovementStats = Unit_Movement.new(5,0,0,0,0,0,0,0,0)

	# Movement Animation
	animation_movement = $"Animation"
	
	# Unit Action state
	UnitActionStatus = Unit_Action_Status.new()

func turn_greyscale_on():
	self.modulate = Color(0.33, 0.34, 0.37, 1)

func turn_greyscale_off():
	self.modulate = Color(1, 1, 1, 1)