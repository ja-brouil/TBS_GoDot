extends "res://Scenes/Events/Event Base.gd"

class_name L2_Event_Part05
# Event Description:
# Allies will chat for a bit then camera will move
# Steps:
# 0.5 Hide all enemies
# 1. Ally dialogue
# 2. Once ally dialogue is done, move camera south
# 3. Event complete
# Part Number: 1

# Dialogue between the characters
var dialogue = [
	"Seth:\n\nHead down south across the river and do a reconnaissance report. Keep an eye out for any suspicious activity.",
	"Seth:\n\nThe weather is terrible tonight and our visibility from here is not great.",
	"Seth:\n\nWe should be secure in this location while the negotiations are on-going however...",
	"Seth:\n\nI am not taking any chances. Are we clear?",
	"Ephraim Soldiers:\n\nYes knight commander!",
	"Seth:\n\nDismissed."
]

var move_actor_3
var move_actor_4

# Set Names for Debug
func _init():
	event_name = "Level 2 Seth gives order to the soldiers."
	event_part = "Part 0.5"
func start():
	for ally in BattlefieldInfo.ally_units.values():
		ally.visible = false
	
	# Actors
	BattlefieldInfo.ally_units["Seth"].visible = true
	BattlefieldInfo.ally_units["Dead Soldier"].visible = true
	BattlefieldInfo.ally_units["Ally 1"].visible = true
	BattlefieldInfo.ally_units["Ally 2"].visible = true
	BattlefieldInfo.ally_units["Ally 3"].visible = true
	BattlefieldInfo.ally_units["Move Me 3"].visible = true
	BattlefieldInfo.ally_units["Move Me 4"].visible = true
	move_actor_3 = BattlefieldInfo.ally_units["Move Me 3"]
	move_actor_4 = BattlefieldInfo.ally_units["Move Me 4"]
	
	# Turn on
	BattlefieldInfo.battlefield_container.get_node("Anim").play("Fade")
	yield(BattlefieldInfo.battlefield_container.get_node("Anim"), "animation_finished")
	
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "move_actor")
	BattlefieldInfo.movement_system_cinematic.connect("individual_unit_finished_moving", self, "hide_actor")
	BattlefieldInfo.movement_system_cinematic.connect("unit_finished_moving_cinema", self, "event_complete")
	
	# Start Text
	BattlefieldInfo.message_system.set_position(Messaging_System.TOP)
	enable_text(dialogue)

func move_actor():
	# Build path to the enemy
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(move_actor_3, BattlefieldInfo.grid[8][12], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(move_actor_4, BattlefieldInfo.grid[8][12], BattlefieldInfo.grid)
	
	# Remove original tile
	move_actor_3.UnitMovementStats.currentTile.occupyingUnit = null
	move_actor_4.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Move Actor
	# Add actors to movement
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(move_actor_3)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(move_actor_4)
	BattlefieldInfo.movement_system_cinematic.is_moving = true

# Hide Actor
func hide_actor(unit):
	BattlefieldInfo.turn_manager.turn = Turn_Manager.WAIT
	unit.visible = false
	BattlefieldInfo.ally_units.erase(unit.UnitStats.identifier)
	unit.UnitMovementStats.currentTile.occupyingUnit = null
	unit.queue_free()
