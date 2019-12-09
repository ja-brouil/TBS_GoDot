extends "res://Scenes/Events/Event Base.gd"

class_name L2_Event_Part2
# Event Description:
# Enemies will chat then camera will pan back to original spot
# Steps:
# 1. Enemy dialogue
# 2. Once enemy dialogue is done, move camera back to original spot
# 3. Event complete
# Part Number: 2

# Dialogue between the characters
var dialogue = [
	"General Vezarius:\n\nDialogue number 2 test!",
	"General Vezarius:\n\nLet us start the fight!"
]

func _init():
	event_name = "Level 2 Event Enemies talk, camera moves, gameplay starts"
	event_part = "Part 2"

func start():
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "move_camera")
	
	# Start Text
	enable_text(dialogue)

# Move Camera back
func move_camera():
	# New Position
	var new_position_for_camera = Vector2(48,0)
	
	# Move Camera
	BattlefieldInfo.main_game_camera.get_node("Tween").connect("tween_all_completed", self, "event_complete")
	BattlefieldInfo.main_game_camera.get_node("Tween").interpolate_property(BattlefieldInfo.main_game_camera, "position", BattlefieldInfo.main_game_camera.position, new_position_for_camera, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	BattlefieldInfo.main_game_camera.get_node("Tween").start()