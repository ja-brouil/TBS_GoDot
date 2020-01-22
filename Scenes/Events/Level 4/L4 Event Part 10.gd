extends "res://Scenes/Events/Event Base.gd"

class_name L4_Event_Part10

# Dialogue between the characters
var dialogue = [
	"Eirika:\n\nWe are close to the capital city! We just need to make it past the Great Fortress Line.",
	"Seth:\n\nThis area was built to protect against pirates and raids from the sea. It looks like the Almaryans have taken control of this area.",
	"Eirika:\n\nWhat is going on? Where is the Royal army?",
	"Seth\n\nI don't know my lady. Something is not right at the capital.",
	"Eirika:\n\nWe need to break though here! If we can capture the village that serves as the base to support the fortress line, we should be able to shut them down."
]

func _init():
	event_name = "Level 3 Before Battle Event"
	event_part = "Part 1"

func start():
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "event_complete")
	
	BattlefieldInfo.message_system.set_position(Messaging_System.BOTTOM)
	
	# Start Text
	enable_text(dialogue)