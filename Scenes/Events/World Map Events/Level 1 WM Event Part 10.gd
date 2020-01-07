extends World_Map_Event

class_name Level1_WM_Event_Part10

# New Game start
var level = "res://Scenes/Battlefield/Chapter 2.tscn"

# Eirika Start and move
var eirika_final = Vector2(-121, -40)
var eirika_initial = Vector2(-168, -93)

func _init():
	# Text
	text_array = [
		"Due to the instability the war has brought, small groups of bandits and thieves took the advantage to cause chaos in the kingdom.",
		"Even though the war recently ended, the Kingdom's army is incapable of patrolling the villages on the border due to the significant loses they incurred.",
		"King Terenas instead sends his daughter Eirika and Knight Commander Seth to investigate a nearby disburtance..."
	]
	
	# Signals needed
	WorldMapScreen.get_node("Eirika/Eirika Tween").connect("tween_completed", self, "after_eirika_move")
	WorldMapScreen.get_node("Message System").connect("no_more_text", self, "after_text")
	
	# Set text position bottom
	WorldMapScreen.get_node("Message System").set_position(Messaging_System.TOP)
	
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
	WorldMapScreen.move_eirika(eirika_final, 5)

func build_map():
	# Create castle
	for c_waypoint in castle_waypoints_array:
		WorldMapScreen.place_castle_waypoint(c_waypoint)
	
	# Create fort
	for f_waypoint in fort_waypoints_array:
		WorldMapScreen.place_fort_waypoint(f_waypoint)
	
	# Villages
	for v_waypoint in village_waypoints_array:
		WorldMapScreen.place_village_waypoint(v_waypoint)

func after_text():
	yield(get_tree().create_timer(0.5), "timeout")
	SceneTransition.change_scene("res://Scenes/Chapter/Chapter Background.tscn", 0.1)
	WorldMapScreen.exit()
	yield(SceneTransition, "scene_changed")
	SceneTransition.get_tree().current_scene.start("1", "Victims of War", level, 2)
	free()