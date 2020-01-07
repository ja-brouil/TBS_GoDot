extends Node2D

var level_music = preload("res://assets/music/Fodlan Winds.ogg")

func _ready():
	#
	BattlefieldInfo.battlefield_container = self
	
	# Set Music for this level
	BattlefieldInfo.music_player.get_node("AllyLevel").stream = level_music
	
	# Set Victory condition
	BattlefieldInfo.victory = false
	BattlefieldInfo.victory_system.clear()
	BattlefieldInfo.victory_system.victory_condition_state = Victory_Checker.ELIMINATE_ALL_ENEMIES
	
	# Start the level
	$"Event System".start_events_queue()

func next_level():
	# stop input
	BattlefieldInfo.cursor.disable_standard("hello world")
	
	# stop music
	BattlefieldInfo.music_player.get_node("AllyLevel").stop()
	
	# Fade Away
	$Anim.play_backwards("Fade")
	yield($Anim, "animation_finished")
	
	# Move to next level
	if !WorldMapScreen.is_inside_tree():
			get_tree().get_root().add_child(WorldMapScreen)
	WorldMapScreen.current_event = Level2_WM_Event_Part10.new()
	WorldMapScreen.connect_to_scene_changer()
	SceneTransition.change_scene_to(WorldMapScreen, 0.1)