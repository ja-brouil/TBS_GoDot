# Represents all the units in the game
extends Node2D

# Movement
var UnitMovementStats
var AnimationMovement

# Unit Stats
var UnitStats

# Inventory
var UnitInventory


func _ready():
	UnitMovementStats = Unit_Movement.new(5,0,0,0,0,0,0,0,0)

func _process(delta):
	# Set the movement of the unit
	if UnitMovementStats.is_moving:
		pass