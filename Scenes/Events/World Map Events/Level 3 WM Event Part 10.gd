extends World_Map_Event

class_name Level3_WM_Event_Part10

# New Game start
var level4 = "res://Scenes/Battlefield/Chapter 4.tscn"

# Eirika Start and move
var eirika_initial = Vector2(-162, -134)
var eirika_final = Vector2(-178, -154)

func _init():
	# Text
	text_array = [
		"Realizing they cannot hold forever, Eirika and her companions decide to escape Fort Merceus by the sea.",
		"They attempt to return to the capital city to warn her father that the Almyryans have no intention of holding the treaty.",
		"On the way there, the nothern winds cause a dense fog to wrap the misty sea..."
	]
	
	# Signals needed
	WorldMapScreen.get_node("Eirika/Eirika Tween").connect("tween_completed", self, "after_eirika_move")
	WorldMapScreen.get_node("Message System").connect("no_more_text", self, "after_text")
	
	# Set text position bottom
	WorldMapScreen.get_node("Message System").set_position(Messaging_System.BOTTOM)
	
	# Place Fort and Castle
	castle_waypoints_array.append(Vector2(-164, -94))
	fort_waypoints_array.append(Vector2(-159, -129))
	village_waypoints_array.append(Vector2(-118, -35))

func run():
	# Set Eirika's initial position
	WorldMapScreen.get_node("Eirika").position = eirika_initial
	
	# 1.5 second pause
	yield(get_tree().create_timer(2), "timeout")
	
	# Move Eirika and start text
	WorldMapScreen.get_node("Message System").start(text_array)
	WorldMapScreen.move_eirika(eirika_final, 3)

func build_map():
	# Create castle
	for c_waypoint in castle_waypoints_array:
		WorldMapScreen.place_castle_waypoint(c_waypoint)
	
	# Create fort
	for f_waypoint in fort_waypoints_array:
		WorldMapScreen.place_fort_waypoint(f_waypoint)

func after_text():
	yield(get_tree().create_timer(0.5), "timeout")
	SceneTransition.change_scene("res://Scenes/Chapter/Chapter Background.tscn", 0.1)
	WorldMapScreen.exit()
	yield(SceneTransition, "scene_changed")
	SceneTransition.get_tree().current_scene.start("4", "Scourge of the Sea", level4, 2)
	queue_free()