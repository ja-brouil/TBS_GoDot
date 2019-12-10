extends Node2D

class_name Event_Base

# Represents an event in the game
####################
# Common Variables #
####################
enum {active, wait}
var current_state = wait

signal event_done
signal move_camera_done
signal move_actor_done
signal enable_text_done
signal enable_combat_done

# Debug purpuses
var event_name
var event_part

#############
# Functions #
#############
# Call this to start the event
func start():
	pass

# Move camera to a location
func move_camera():
	pass

# Move an actor to a location
func move_actor():
	pass

# Start the text dialogue
func enable_text(text_array: Array):
	BattlefieldInfo.message_system.start(text_array)

# Start combat between two actors
func enable_combat():
	pass

# Force the player to do a certain instruction
func check_player_input():
	pass

# Call this to end this event
func event_complete():
	emit_signal("event_done")