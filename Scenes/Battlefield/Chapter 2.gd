extends Node2D

# Container for the entire level
# Add extra functions that might be needed here

var level_music = preload("res://assets/music/Fodlan Winds.ogg")

var chapter_title = "Chapter 1: Victims of War"

var enemy_commander_name = "Marcus"

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
	BattlefieldInfo.enemy_commander = BattlefieldInfo.enemy_units[enemy_commander_name]
	
	# Load the events
	BattlefieldInfo.event_system.clear()
	BattlefieldInfo.event_system.add_event(L1_Event_Part_10.new())
	BattlefieldInfo.event_system.add_event(L1_Event_Part_20.new())
	BattlefieldInfo.event_system.add_event(L1_Event_Part_30.new())
	
	# Add the players from the y sort to the battle field y sort
	for player_unit in BattlefieldInfo.y_sort_player_party.get_children():
		BattlefieldInfo.y_sort_player_party.remove_child(player_unit)
		BattlefieldInfo.current_level.get_node("YSort").add_child(player_unit)
	
	# Only auto start if level loaded is not set to loaded
	if !BattlefieldInfo.save_load_system.is_loading_level:
		BattlefieldInfo.event_system.start_events_queue()
	

# Additional Loss
# If Seth dies on this level you also lose
func check_loss():
	return BattlefieldInfo.ally_units.has("Seth")

func next_level():
	# Remove any ally units that are still alive
	for unit in BattlefieldInfo.current_level.get_node("YSort").get_children():
		if unit.UnitMovementStats.is_ally:
			BattlefieldInfo.current_level.get_node("YSort").remove_child(unit)
			BattlefieldInfo.y_sort_player_party.add_child(unit)
	
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
	
	# Clear the events system
	BattlefieldInfo.event_system.clear()
