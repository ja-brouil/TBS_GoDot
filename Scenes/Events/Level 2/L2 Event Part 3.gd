extends "res://Scenes/Events/Event Base.gd"

class_name L2_Event_Part3
# Event Description:
# Camera pans back to original location, all allies are now visible, Eirika and Seth have a few last words and then into combat we go
# Steps:
# 1. Camera pans back to original location
# 2. Dialogue
# 3. Move Units into the castle
# 4. Gameplay
# Part Number: 3

# Dialogue between the characters
var dialogue = [
	"Seth:\n\nWe have been betrayed! Someone has informed them of our location!",
	"Seth:\n\nGet the Pegasus Horses ready immediately!",
	"Eirika:\n\nWhat about the forward guard! We cannot abbadon them!",
	"Ephraim Soldier:\n\nWe must get you to safety first my lady! We are ready to lay down our lives down for you.",
	"Ephraim Soldier:\n\nYou must escape! We know that you will come back for us one day!",
	"Eirika:\n\nThank you... I will return, I swear it!",
	"Seth:\n\nMake haste! We don't time have time to lose. We cannot defeat them all so let's buy enough time to escape.",
	"Ephraim Soldier:\n\nYes sir! You heard the Knight Commander! Get those Pegasi ready NOW!"
]

# Move these actors and combat
var move_actor_1
var move_actor_2

func _init():
	event_name = "Level 2 Before Battle Event"
	event_part = "Part 3"

func start():
	# Find Move Soldier
	for ally in BattlefieldInfo.ally_units:
		if ally.UnitStats.name == "Move Me 1":
			move_actor_1 = ally
		
		if ally.UnitStats.name == "Move Me 2":
			move_actor_2 = ally
	
	# Activate all the enemies
	for enemy in BattlefieldInfo.enemy_units:
		enemy.visible = true
	
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "move_actor")
	
	# Movement System Connect
	BattlefieldInfo.movement_system_cinematic.connect("unit_finished_moving_cinema", self, "event_complete")
	BattlefieldInfo.movement_system_cinematic.connect("individual_unit_finished_moving", self, "hide_actor")
	
	# Start Text
	enable_text(dialogue)

func move_actor():
	# Build path to the enemy
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(move_actor_1, BattlefieldInfo.grid[9][4], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(move_actor_2, BattlefieldInfo.grid[9][4], BattlefieldInfo.grid)
	
	# Remove original tile
	move_actor_1.UnitMovementStats.currentTile.occupyingUnit = null
	move_actor_2.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Move Actor
	# Set Camera on unit
	var movement_camera = preload("res://Scenes/Camera/MovementCamera.tscn").instance()
	move_actor_1.add_child(movement_camera)
	movement_camera.current = true
	
	# Add actors to movement
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(move_actor_1)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(move_actor_2)
	BattlefieldInfo.movement_system_cinematic.is_moving = true

# Hide Actor
func hide_actor(unit):
	BattlefieldInfo.turn_manager.turn = Turn_Manager.WAIT
	unit.visible = false
	BattlefieldInfo.ally_units.erase(unit)
	unit.UnitMovementStats.currentTile.occupyingUnit = null
	unit.queue_free()