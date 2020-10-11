extends Node

# Signals
signal parsing_events_complete

# Data
var event_data = []

# Load the level's events
func load_event_data(file_location) -> void:
	var new_file = File.new()
	
