# Represents all the units in the game
extends Node2D

var UnitMovementStats

func _ready():
	UnitMovementStats = Unit_Movement.new(5,0,0,0,0,0,0,0)