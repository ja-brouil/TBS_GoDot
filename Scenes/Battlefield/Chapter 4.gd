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
	BattlefieldInfo.main_game_camera.position = Vector2(48, 0)
	
	# Set cursor
	BattlefieldInfo.cursor.position = Vector2(144,80)
	
	# Set Music for this level
	BattlefieldInfo.music_player.get_node("AllyLevel").stream = level_music
	
	# Set Victory condition
	BattlefieldInfo.victory = false
	BattlefieldInfo.victory_system.clear()
	BattlefieldInfo.victory_system.victory_condition_state = Victory_Checker.ELIMINATE_ALL_ENEMIES
	
	# Set enemy commander
	BattlefieldInfo.enemy_commander = BattlefieldInfo.enemy_units["Rolod"]
	
	# Add Events and reset manager
	BattlefieldInfo.event_system.current_state = Event_System.starting_events
	BattlefieldInfo.event_system.add_event(L3_Event_Part10.new())
	
	# Prep mode
	preperation_mode()
	
#	# Show Ally units
	for ally_unit in BattlefieldInfo.ally_units.values():
		ally_unit.visible = true
	
	# Remove other one
	get_node("/root/Level/Chapter 3").queue_free()   

func next_level():
	pass

func start_battle():
	# Start the level
	$"Event System".start_events_queue()

func preperation_mode():
	# Turn on prep
	BattlefieldInfo.preparation_screen.start(chapter_title, BattlefieldInfo.victory_text, "res://Scenes/Intro Screen/Intro Screen.tscn", prep_music_choice)
	
	# Turn off turn manager
	BattlefieldInfo.turn_manager.turn = Turn_Manager.WAIT
	
	# Set all units to move for the allies
	for ally_unit in BattlefieldInfo.ally_units.values():
		ally_unit.UnitActionStatus.set_current_action(Unit_Action_Status.MOVE)