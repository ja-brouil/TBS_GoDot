extends Node2D

# Container for the entire level
# Add extra functions that might be needed here

var level_music = preload("res://assets/music/The Long Road.ogg")

var chapter_title = "3\nScourge of the Sea"
var prep_music_choice = "B"

func _ready():
	# Container for this
	BattlefieldInfo.level_container = self
	
	# Set Camera to new spot
	BattlefieldInfo.main_game_camera.position = Vector2(128, 0)
	
	# Set cursor
	BattlefieldInfo.cursor.position = Vector2(240,32)
	
	# Set Music for this level
	BattlefieldInfo.music_player.get_node("AllyLevel").stream = level_music
	
	# Set Victory condition
	BattlefieldInfo.victory = false
	BattlefieldInfo.victory_system.clear()
	BattlefieldInfo.victory_system.victory_condition_state = Victory_Checker.ELIMINATE_ALL_ENEMIES
	
	# Set enemy commander
	BattlefieldInfo.enemy_commander = BattlefieldInfo.enemy_units["Rolod"]
	
	# Add Events and reset manager
	BattlefieldInfo.event_system.clear()
	BattlefieldInfo.event_system.current_state = Event_System.starting_events
	BattlefieldInfo.event_system.add_event(L3_Event_Part10.new())
	BattlefieldInfo.event_system.add_event(L3_Event_Part20.new())
	BattlefieldInfo.event_system.add_event(L3_Event_Part30.new())
	
	# Prep mode
	preperation_mode()
	
#	# Show Ally units
	for ally_unit in BattlefieldInfo.ally_units.values():
		ally_unit.visible = true
	
	# Remove dark from level
	BattlefieldInfo.battlefield_container.modulate = Color(1,1,1,1)
	
	# Remove other one
	get_node("/root/Level/Chapter 3").queue_free()   

func next_level():
		#stop input
	BattlefieldInfo.cursor.disable_standard("hello world")
	
	# stop music
	BattlefieldInfo.music_player.get_node("AllyLevel").stop()
	
	# Fade Away
	BattlefieldInfo.battlefield_container.get_node("Anim").play_backwards("Fade")
	yield(BattlefieldInfo.battlefield_container.get_node("Anim"), "animation_finished")
	
	# Move to next level 
	WorldMapScreen.current_event = Level4_WM_Event_Part10.new()
	WorldMapScreen.connect_to_scene_changer()
	SceneTransition.change_scene_to(WorldMapScreen, 0.1)

func start_battle():
	# Start the level
	BattlefieldInfo.event_system.start_events_queue()
	BattlefieldInfo.music_player.get_node("AllyLevel").play(0)

func preperation_mode():
	# Turn on prep
	BattlefieldInfo.preparation_screen.start(chapter_title, BattlefieldInfo.victory_text, "res://Scenes/Intro Screen/Intro Screen.tscn", prep_music_choice)
	
	# Show Cursor
	BattlefieldInfo.cursor.visible = true
	
	# Show UI
	BattlefieldInfo.battlefield_ui.get_node("Battlefield HUD").visible = true
	
	# Turn off turn manager
	BattlefieldInfo.turn_manager.turn = Turn_Manager.WAIT
	
	# Set all units to move for the allies
	for ally_unit in BattlefieldInfo.ally_units.values():
		ally_unit.UnitActionStatus.set_current_action(Unit_Action_Status.MOVE)
