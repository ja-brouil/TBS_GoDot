extends "res://Scenes/Events/Event Base.gd"

class_name L3_Event_Part10

# Dialogue between the characters
var dialogue = [
	"Eirika:\n\nWe've ran into pirates!"
]

func _init():
	event_name = "Level 3 Before Battle Event"
	event_part = "Part 1"

func start():
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "event_complete")
	# Start Text
	enable_text(dialogue)