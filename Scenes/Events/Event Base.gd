extends Node2D

class_name Base_Event

# Represents an event in the game
####################
# Common Variables #
####################
var next_event

signal event_done
signal move_camera_done
signal move_actor_done
signal enable_text_done
signal enable_combat_done

#############
# Functions #
#############
# Move camera to a location
func move_camera(new_position: Vector2):
	pass

# Move an actor to a location
func move_actor(new_position: Cell, actor: Battlefield_Unit):
	pass

# Start the text dialogue
func enable_text(text_array: Array):
	pass

# Start combat between two actors
func enable_combat(actor1: Battlefield_Unit, actor2: Battlefield_Unit):
	pass

# Force the player to do a certain instruction
func check_player_input():
	pass