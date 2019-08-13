# Represents all the units in the game
extends Node2D

# Movement
var UnitMovementStats
var animation_movement

# Unit Stats
var UnitStats

# Inventory
var UnitInventory

func _ready():
	# Movement Stats
	UnitMovementStats = Unit_Movement.new(15,0,0,0,0,0,0,0,0)
	
	# Movement Animation
	animation_movement = $"Animation"