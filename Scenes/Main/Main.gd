extends Node2D

# Global variables needed for the entire battle field scene
var current_Unit_Selected: Node2D

func get_Current_Unit_Selected() -> Node2D:
	return current_Unit_Selected

func set_Current_Unit_Selected(Current_Unit_Selected: Node2D) -> void:
	current_Unit_Selected = Current_Unit_Selected