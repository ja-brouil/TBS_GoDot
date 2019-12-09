extends "res://Scenes/Events/Event Base.gd"

class_name L2_Event_Part1
# Event Description:
# Allies will chat for a bit then camera will move
# Steps:
# 1. Ally dialogue
# 2. Once ally dialogue is done, move camera south
# 3. Event complete
# Part Number: 1

# Dialogue between the characters
var dialogue = [
	"Seth:\n\nMy lady, what seems to be troubling you?",
	"Eirika:\n\nSeth...",
	"Eirika:\n\nDo you really think we can reach a truce with them?",
	"Seth:\n\nWe can only continue forward your highness. I trust your father will make the right decision.",
	"Eirika:\n\nI hope you are right.",
	"Eirika:\n\nWill we be alright here at PLACEHOLDER NAME? Father said this was the safest place to be right now.",
	"Seth:\n\nPLACEHOLDER NAME is the safest place we can be right now. It is surrounded by water and high mountains.",
	"Seth:\n\nThis fortress was built back in the day in secret for the Royal Family to escape if they ever needed it.",
	"Seth:\n\nWe have never had to use it until now...",
	"Eirika:\n\nIt's quite alright Seth...",
	"Eirika:\n\nWhat..."
]

# Set Names for Debug
func _init():
	event_name = "Level 2 Event Eirika and allies talk, camera moves"
	event_part = "Part 1"

func start():
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "move_camera")
	
	# Start Text
	enable_text(dialogue)

func move_camera():
	# New Position
	var new_position_for_camera = Vector2(0,190)
	
	# Move Camera
	BattlefieldInfo.main_game_camera.get_node("Tween").connect("tween_all_completed", self, "event_complete")
	BattlefieldInfo.main_game_camera.get_node("Tween").interpolate_property(BattlefieldInfo.main_game_camera, "position", BattlefieldInfo.main_game_camera.position, new_position_for_camera, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	BattlefieldInfo.main_game_camera.get_node("Tween").start()