# Represents all the units in the game
extends Node2D

class_name Battlefield_Unit

# Movement
var UnitMovementStats
var animation_movement

# Unit Stats
var UnitStats

# Inventory
var UnitInventory

func _ready():
	pass
	# Movement Stats
	UnitMovementStats = Unit_Movement.new(10,0,0,0,0,0,0,0,0)

	# Movement Animation
	animation_movement = $"Animation"