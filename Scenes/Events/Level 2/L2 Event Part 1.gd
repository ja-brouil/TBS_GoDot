extends "res://Scenes/Events/Event Base.gd"

class_name L2_Event_Part1
# Event Description:
# Allies will chat for a bit then camera will move
# Steps:
# 0.5 Hide all enemies
# 1. Ally dialogue
# 2. Once ally dialogue is done, move camera south
# 3. Event complete
# Part Number: 1

# Dialogue between the characters
var dialogue = [
	"Seth:\n\nYour highness, it is cold and raining outside. Please come back inside.",
	"Eirika:\n\nI bear a heavy burden Seth. I cannot bear to see my people suffer any longer...",
	"Eirika:\n\nDo you really think being here is the right decision?",
	"Seth:\n\nWe can only continue forward your highness. I trust your father will make the right decision.",
	"Eirika:\n\nYes... I hope you are right.",
	"Eirika:\n\nWill we be alright here at Merceus? Father said this was the safest place to be right now.",
	"Seth:\n\nMerceus is the safest place we can be right now. It is surrounded by water and high mountains.",
	"Seth:\n\nIt is not very well known to the outside world and given it's remote location, this is the best place to be right now.",
	"Seth:\n\nI should check in with the forward guard. Please head back inside your highness.",
	"Eirika:\n\nI will. Thank you Seth.",
	"Ephraim Soldier:\n\nHey, what the...",
	"Eirika:\n\n...?",
]

# Set Names for Debug
func _init():
	event_name = "Level 2 Event Eirika and allies talk, camera moves"
	event_part = "Part 1"

func start():
	# Play intro song
	BattlefieldInfo.music_player.get_node("Unfufilled").play(0)
	
	for ally in BattlefieldInfo.ally_units:
		if ally.UnitStats.name == "Eirika" || ally.UnitStats.name == "Seth" || ally.UnitStats.name == "Dead Soldier" || ally.UnitStats.name == "Ephraim Soldier":
			continue
		else:
			ally.visible = false
	
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
	BattlefieldInfo.music_player.get_node("Unfufilled").stop()