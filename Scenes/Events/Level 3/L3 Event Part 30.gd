extends "res://Scenes/Events/Event Base.gd"

class_name L3_Event_Part30

# Dialogue between the characters
var dialogue = [
	"Mage:\n\nShut up you dumb pirates!",
	"Mage:\n\nYou better capture her alive!"
]

func _init():
	event_name = "Level 4 Before battle"
	event_part = "Part 3"

func start():
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "move_camera_2")
	
	BattlefieldInfo.message_system.set_position(Messaging_System.TOP)
	
	move_camera()

func move_camera():
	# New Position
	var new_position_for_camera = Vector2(0, 192)
	
	# Move Camera and Remove old camera
	BattlefieldInfo.main_game_camera.get_node("Tween").connect("tween_all_completed", self, "enable_text_no_array")
	BattlefieldInfo.main_game_camera.get_node("Tween").interpolate_property(BattlefieldInfo.main_game_camera, "position", BattlefieldInfo.main_game_camera.position, new_position_for_camera, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	BattlefieldInfo.main_game_camera.get_node("Tween").start()

func move_camera_2():
	# New Position
	var new_position_for_camera = Vector2(128, 0)
	
	# Move Camera and Remove old camera
	BattlefieldInfo.main_game_camera.get_node("Tween").connect("tween_all_completed", self, "event_complete")
	BattlefieldInfo.main_game_camera.get_node("Tween").interpolate_property(BattlefieldInfo.main_game_camera, "position", BattlefieldInfo.main_game_camera.position, new_position_for_camera, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	BattlefieldInfo.main_game_camera.get_node("Tween").start()

func enable_text_no_array():
	BattlefieldInfo.main_game_camera.get_node("Tween").disconnect("tween_all_completed", self, "enable_text_no_array")
	BattlefieldInfo.message_system.start(dialogue)