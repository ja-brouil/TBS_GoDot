extends "res://Scenes/Events/Event Base.gd"

class_name Spawn_Event

# Base spawn enemy class

signal done_spawning

func _ready():
	# Listen to the enemy turn
	BattlefieldInfo.turn_manager.connect("enemy_turn_increased", self, "process_spawning_event")

func process_spawning_event():
	pass

func done_spawning_enemies():
	self.queue_free()