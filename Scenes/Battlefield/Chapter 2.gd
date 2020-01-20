extends Node2D

# Container for the entire level
# Add extra functions that might be needed here

var level_music = preload("res://assets/music/Fodlan Winds.ogg")

var chapter_title = "Chapter 1: Victims of War"

func _ready():
	# Container for this
	BattlefieldInfo.level_container = self
	
	# Set Music for this level
	BattlefieldInfo.music_player.get_node("AllyLevel").stream = level_music
	
	# Set Victory condition
	BattlefieldInfo.victory = false
	BattlefieldInfo.victory_system.clear()
	BattlefieldInfo.victory_system.victory_condition_state = Victory_Checker.ELIMINATE_ALL_ENEMIES
	
	# Set enemy commander
	BattlefieldInfo.enemy_commander = BattlefieldInfo.enemy_units["Marcus"]
	
	# Load the events
	BattlefieldInfo.event_system.add_event(L1_Event_Part_10.new())
	BattlefieldInfo.event_system.add_event(L1_Event_Part_20.new())
	BattlefieldInfo.event_system.add_event(L1_Event_Part_30.new())
	
	BattlefieldInfo.event_system.start_events_queue()

# Additional Loss
# If Seth dies on this level you also lose
func check_loss():
	return BattlefieldInfo.ally_units.has("Seth")

func next_level():
	# stop input
	BattlefieldInfo.cursor.disable_standard("hello world")
	
	# stop music
	BattlefieldInfo.music_player.get_node("AllyLevel").stop()
	
	# Fade Away
	BattlefieldInfo.battlefield_container.get_node("Anim").play_backwards("Fade")
	yield(BattlefieldInfo.battlefield_container.get_node("Anim"), "animation_finished")
	
	# Move to next level
	WorldMapScreen.visible = true
	WorldMapScreen.current_event = Level2_WM_Event_Part10.new()
	WorldMapScreen.connect_to_scene_changer()
	SceneTransition.change_scene_to(WorldMapScreen, 0.1)