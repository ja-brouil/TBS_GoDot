extends "res://Scenes/Events/Event Base.gd"

class_name L3_Event_Part10

# Dialogue between the characters
var dialogue = [
	"Seth:\n\nDamn it! These Almaryans hired these pirates to intercept us.",
	"Seth:\n\nOn top of that some of their mages are on their ship as well.",
	"Seth:\n\nLet's get rid of them as move on! We can't afford to lose time.",
	"Eirika:\n\nWe need to hurry and reach the capital city quickly to warn my father!."
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