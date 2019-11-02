extends Node

class_name Unit_Action_Status

# Listings:
# Move -> Can do everything
# Action -> Can do one action (Attack, Heal, Cast Magic, inventory, etc...)
# Done -> Cannot do anything anymore
enum {MOVE, ACTION, DONE}
var current_action_status setget set_current_action, get_current_action

# All Units are set to move
func _init():
	current_action_status = MOVE

func get_current_action():
	return current_action_status

func set_current_action(action):
	current_action_status = action