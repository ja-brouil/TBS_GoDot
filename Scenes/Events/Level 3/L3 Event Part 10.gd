extends "res://Scenes/Events/Event Base.gd"

class_name L3_Event_Part10

# Dialogue between the characters
var dialogue = [
	"Seth@assets/units/cavalier/seth mugshot.png@Damn it! These Almaryans knew the only escape route as by the Northern Sea.",
	"Eirika@assets/units/eirika/eirika mugshot.png@We can't afford to waste time here. Let's get rid of them and hurry on the capital city.",
	"Eirika@assets/units/eirika/eirika mugshot.png@Everyone, watch out for their dark mages!"
]

func _init():
	event_name = "Level 3 Before Battle Event"
	event_part = "Part 1"
	path = "res://Scenes/Events/Level 3/L3 Event Part 10.gd"

func start():
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "event_complete")
	
	BattlefieldInfo.message_system.set_position(Messaging_System.BOTTOM)
	
	# Start Text
	enable_text(dialogue)
