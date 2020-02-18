extends "res://Scenes/Events/Event Base.gd"

class_name L3_Event_Part20

# Dialogue between the characters
var dialogue = [
	"Rolod@assets/units/bandit/bandit mugshot.png@Hahaha! We've got you now Eirika!",
	"Rolod@assets/units/bandit/bandit mugshot.png@That sweet bounty on your head will be ours!",
	"Rolod@assets/units/bandit/bandit mugshot.png@Get her boys!",
]

func _init():
	event_name = "Level 3 Before Battle Event"
	event_part = "Part 1"

func start():
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "event_complete")
	
	BattlefieldInfo.message_system.set_position(Messaging_System.TOP)
	
	move_camera()

func move_camera():
	# New Position
	var new_position_for_camera = Vector2(128,240)
	
	# Move Camera and Remove old camera
	BattlefieldInfo.main_game_camera.get_node("Tween").connect("tween_all_completed", self, "enable_text_no_array")
	BattlefieldInfo.main_game_camera.get_node("Tween").interpolate_property(BattlefieldInfo.main_game_camera, "position", BattlefieldInfo.main_game_camera.position, new_position_for_camera, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	BattlefieldInfo.main_game_camera.get_node("Tween").start()

func enable_text_no_array():
	BattlefieldInfo.message_system.start(dialogue)
