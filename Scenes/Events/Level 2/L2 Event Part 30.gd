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
	"Seth@assets/units/cavalier/seth mugshot.png@Almaryan soldiers here?!?",
	"Seth@assets/units/cavalier/seth mugshot.png@That is General Vezarius, the right hand man of the Emperor.",
	"Seth@assets/units/cavalier/seth mugshot.png@Your father was right Lady Eirika. Something is amiss here.",
	"Soldiers@assets/units/soldier/soldier_blue_portrait.png@Get to the forward guard! Protect her highness! Move it!",
]

# Move these actors and combat
var move_actor_1
var move_actor_2

func _init():
	event_name = "Level 2 Before Battle Event"
	event_part = "Part 3"

func start():
	# Find Move Soldier
	move_actor_1 = BattlefieldInfo.ally_units["Move Me 1"]
	move_actor_2 = BattlefieldInfo.ally_units["Move Me 2"]
	
	# Activate all the enemies
	for enemy in BattlefieldInfo.enemy_units.values():
		enemy.visible = true
	
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "move_actor")
	
	# Movement System Connect
	BattlefieldInfo.movement_system_cinematic.connect("unit_finished_moving_cinema", self, "event_complete")
	BattlefieldInfo.movement_system_cinematic.connect("individual_unit_finished_moving", self, "hide_actor")
	
	# Start Text
	enable_text(dialogue)

func move_actor():
	# Build path to the location
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(move_actor_1, BattlefieldInfo.grid[9][13], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(move_actor_2, BattlefieldInfo.grid[9][13], BattlefieldInfo.grid)
	
	# Remove original tile
	move_actor_1.UnitMovementStats.currentTile.occupyingUnit = null
	move_actor_2.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Add actors to movement
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(move_actor_1)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(move_actor_2)
	BattlefieldInfo.movement_system_cinematic.is_moving = true

# Hide Actor
func hide_actor(unit):
	BattlefieldInfo.turn_manager.turn = Turn_Manager.WAIT
	unit.visible = false
	BattlefieldInfo.ally_units.erase(unit.UnitStats.identifier)
	unit.UnitMovementStats.currentTile.occupyingUnit = null
	unit.queue_free()
