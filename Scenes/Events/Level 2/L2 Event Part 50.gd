extends "res://Scenes/Events/Event Base.gd"

class_name L2_Event_Part5
# Event Description:
# Camera pans back to original location, all allies are now visible, Eirika and Seth have a few last words and then into combat we go
# Steps:
# 1. Camera pans back to original location
# 2. Dialogue
# 3. Move Units into the castle
# 4. Gameplay
# Part Number: 3

# Dialogue between the characters
var dialogue = [
	"Soldiers@assets/units/soldier/soldier_blue_portrait.png@Protect Lady Eirika with your lives!",
	"Soldiers@assets/units/soldier/soldier_blue_portrait.png@Don't let a single one of those bastards get through!",
	"Soldiers@assets/units/soldier/soldier_blue_portrait.png@For Ephraim!"
]

func _init():
	event_name = "Level 2 Before Battle Event"
	event_part = "Part 3"

func start():
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "move_camera")
	# Start Text
	enable_text(dialogue)
	
func move_camera():
	# New Position
	var new_position_for_camera = Vector2(48,0)
	
	# Move Camera and Remove old camera
	BattlefieldInfo.main_game_camera.get_node("Tween").connect("tween_all_completed", self, "event_complete")
	BattlefieldInfo.main_game_camera.get_node("Tween").interpolate_property(BattlefieldInfo.main_game_camera, "position", BattlefieldInfo.main_game_camera.position, new_position_for_camera, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	BattlefieldInfo.main_game_camera.get_node("Tween").start()
