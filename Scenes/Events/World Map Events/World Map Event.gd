extends Node

class_name World_Map_Event

# Represents an event in the world map
# World map
onready var world_map = WorldMapScreen

# Text
var text_array = []

# Way points arrays
var castle_waypoints_array = []
var fort_waypoints_array = []

# Call this to run the event
func run():
	pass

func build_map():
	pass

# Functions for events
func after_text():
	pass

func after_camera_move(object, key):
	pass

func after_eirika_move(object, key):
	pass