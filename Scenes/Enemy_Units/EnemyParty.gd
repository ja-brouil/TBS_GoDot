# Controls the enemy party statistics
extends Node2D

func _ready():
	# Set all child nodes' to enemies
	for enemy in get_children():
		enemy.UnitMovementStats.is_ally = false