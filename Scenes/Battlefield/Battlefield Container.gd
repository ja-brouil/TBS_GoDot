extends Node2D

var level_music = preload("res://assets/music/Chasing Daybreak.ogg")

var chapter_title = "Chapter 2: Fort Merceus"

func _ready():
	BattlefieldInfo.battlefield_container = self
	
	# Set Music
	BattlefieldInfo.music_player.get_node("AllyLevel").stream = level_music
	
	# Set victory condition
	BattlefieldInfo.victory = false
	BattlefieldInfo.victory_system.clear()
	BattlefieldInfo.victory_system.victory_condition_state = Victory_Checker.SURVIVE
	BattlefieldInfo.victory_system.turns_left_to_survive = 2
	
	# Enemy Commander
	BattlefieldInfo.enemy_commander = BattlefieldInfo.enemy_units["Vezarius"]
	
	# Start the level
	$"Event System".start_events_queue()

func check_loss():
	return BattlefieldInfo.ally_units.has("Seth")

func next_level():
	#stop input
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
	
	# This should go to the world map normally but for testing purposes, let's just start chapter 4
	var chapter4 = "res://Scenes/Battlefield/Chapter 4.tscn"
	SceneTransition.change_scene("res://Scenes/Battlefield/Chapter 4.tscn", 0.1)