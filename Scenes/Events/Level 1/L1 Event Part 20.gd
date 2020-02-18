extends Event_Base

class_name L1_Event_Part_20

# Event Description:
# Bandit Leader talks

# Dialogue between the characters
var dialogue = [
	# Japanese
#	"マークス:\n\nおい、誰だ？",
#	"マークス:\n\n俺たちはこの村を支配してる！出ろ！",
#	"マークス:\n\n待って。。。",
#	"マークス:\n\nお前は王女のエイリーカだ！",
#	"マークス:\n\nアルマイリやンはお前の首を多く払う！",
#	"マークス:\n\nエイリーカの首を持って来てくれ！行け！"
	
	# English
	"Marcus@assets/units/bandit/bandit mugshot.png@What do we have here?!?",
	"Marcus@assets/units/bandit/bandit mugshot.png@A princess and her knight!",
	"Marcus@assets/units/bandit/bandit mugshot.png@The Almaryans will pay me handsomely for your head!",
	"Marcus@assets/units/bandit/bandit mugshot.png@Get her boys! 20 extra silver to whoever brings me her head, 40 if alive!"
]

# Set Names for Debug
func _init():
	event_name = "Level 1 Bandit Leader Talk"
	event_part = "Part 20"

func start():
	# Start music
	BattlefieldInfo.music_player.get_node("AllyLevel").play(0)
	
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "move_camera")
	
	# Start Text
	BattlefieldInfo.message_system.set_position(Messaging_System.BOTTOM)
	enable_text(dialogue)

# Move Camera back
func move_camera():
	# New Position
	var new_position_for_camera = Vector2(0,80)
	
	# Move Camera and Remove old camera
	BattlefieldInfo.main_game_camera.get_node("Tween").connect("tween_all_completed", self, "event_complete")
	BattlefieldInfo.main_game_camera.get_node("Tween").interpolate_property(BattlefieldInfo.main_game_camera, "position", BattlefieldInfo.main_game_camera.position, new_position_for_camera, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	BattlefieldInfo.main_game_camera.current = true
	BattlefieldInfo.main_game_camera.get_node("Tween").start()
