extends Node2D

# Container for the entire level
# Add extra functions that might be needed here

var level_music = preload("res://assets/music/Fodlan Winds.ogg")

func _ready():
	# Container access
	BattlefieldInfo.battlefield_container = self
	
	# Set Music for this level
	BattlefieldInfo.music_player.get_node("AllyLevel").stream = level_music
	
	# Set Victory condition
	BattlefieldInfo.victory = false
	BattlefieldInfo.victory_system.clear()
	BattlefieldInfo.victory_system.victory_condition_state = Victory_Checker.ELIMINATE_ALL_ENEMIES
	
	# Start the level
	$"Event System".start_events_queue()

# Additional Loss
# If Seth dies on this level you also lose
func check_loss():
	return BattlefieldInfo.ally_units.has("Seth")

func next_level():
	# stop input
	BattlefieldInfo.cursor.disable_standard("hello world")
	
	# Save the current nodes only for allies
	for child in get_node("Level/YSort").get_children():
		if child.UnitMovementStats.is_ally:
			child.UnitMovementStats.clear_arrays()
			child.get_parent().remove_child(child)
	
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