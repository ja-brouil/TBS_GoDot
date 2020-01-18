extends CanvasLayer

# Controls the Preparation Screen

# Text for all the side panels
const SELECT_UNITS_TEXT = "Select which allies to send into this battle. The amount of units you may pick is limited and differs by level."
const INVENTORY_TEXT = "Manage your allies' items and inventory. You may exchange items and access the convoy here."
const CHECK_MAP = "View the battlefield. You can preview enemies and where they are located. Additionally, change your allies starting positions here."
const MARKETPLACE_TEXT = "Buy and sell items for your allies here."
const SAVE = "Save the game and any changes made."

# Array to hold all the panels
var all_options_array = ["Select", "Inventory", "Map", "Market", "Save"]
var current_option = all_options_array[0]
var current_option_number = 0

# Level
var level

# Hand reset
var hand_default_position = Vector2(3.5, 58.0)
var hand_movement_vector= Vector2(0, 17)

func _ready():
	set_process_input(false)
	
	# Set self
	BattlefieldInfo.preparation_screen = self
	
	# Set Stuff
	start(get_parent().chapter_title, BattlefieldInfo.victory_text, "res://Scenes/Intro Screen/Intro Screen.tscn", get_parent().prep_music_choice)

func start(chapter_text, victory_text, path_to_next_level, prep_song):
	# Set the y tree to the new level and set the units to the new path
	for ally_unit in BattlefieldInfo.ally_units.values():
		if ally_unit == BattlefieldInfo.ally_units["Eirika"]:
			continue
		else:
			ally_unit.UnitMovementStats.currentTile = null
	
	for ally_unit in BattlefieldInfo.ally_units.values():
		if ally_unit.UnitMovementStats.currentTile == null:
			for swap_point in BattlefieldInfo.swap_points:
				if swap_point.occupyingUnit == null:
					ally_unit.position = swap_point.position
					ally_unit.UnitMovementStats.currentTile = swap_point
					swap_point.occupyingUnit = ally_unit
					BattlefieldInfo.current_level.get_node("YSort").add_child(ally_unit)
					break
	
	# Heal Units
	for ally_unit in BattlefieldInfo.ally_units.values():
		ally_unit.UnitStats.current_health = ally_unit.UnitStats.max_health
	
	# Play Music
	play_song(prep_song)
	
	# Set Text
	$"Prep Screen Control/Chapter Title Background/Chapter Title".text = str("Chapter ", chapter_text)
	$"Prep Screen Control/Victory Condition".text = victory_text
	
	# Reset Hand
	$"Prep Screen Control/Hand Selector".rect_position = hand_default_position
	
	# Reset option
	current_option_number = 0
	current_option = all_options_array[current_option_number]
	
	# Fade and allow input
	$Anim.play("Fade")
	yield($Anim, "animation_finished")
	set_process_input(true)

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		# Can we move up?
		if current_option_number - 1 >= 0:
			# Update options
			current_option_number -= 1
			current_option = all_options_array[current_option_number]
			
			# Move hand down
			$"Prep Screen Control/Hand Selector".rect_position -= hand_movement_vector
			$"Prep Screen Control/Hand Selector/Move".play(0)
			
			# Set Text
			set_side_text()
	elif Input.is_action_just_pressed("ui_down"):
		# Can we move down?
		if current_option_number + 1 <= all_options_array.size() - 1:
			# Update options
			current_option_number += 1
			current_option = all_options_array[current_option_number]
			
			# Move hand down
			$"Prep Screen Control/Hand Selector".rect_position += hand_movement_vector
			$"Prep Screen Control/Hand Selector/Move".play(0)
			
			# Set Text
			set_side_text()
	elif Input.is_action_just_pressed("ui_accept"):
		process_selection()
		$"Prep Screen Control/Hand Selector/Accept".play(0)
		print("Selected process! Process: ", current_option)
	elif Input.is_action_just_pressed("start_battle"):
		$"Start Combat".play(0)
		start_battle()
		
func set_side_text():
	match current_option:
		"Select":
			$"Prep Screen Control/Side Panel Text".text = SELECT_UNITS_TEXT
		"Inventory":
			$"Prep Screen Control/Side Panel Text".text = INVENTORY_TEXT
		"Map":
			$"Prep Screen Control/Side Panel Text".text = CHECK_MAP
		"Market":
			$"Prep Screen Control/Side Panel Text".text = MARKETPLACE_TEXT
		"Save":
			$"Prep Screen Control/Side Panel Text".text = SAVE

func process_selection():
	match current_option:
		"Select":
			$"Prep Screen Control/Side Panel Text".text = SELECT_UNITS_TEXT
		"Inventory":
			$"Prep Screen Control/Side Panel Text".text = INVENTORY_TEXT
		"Map":
			# Make this go invisible
			$Anim.play("Invi")
			
			# Turn this off
			turn_off()
			
			# Set Camera
			BattlefieldInfo.main_game_camera.current = true
			
			# Turn on the blue tiles
			for blueTile in BattlefieldInfo.swap_points:
				blueTile.get_node("MovementRangeRect").turnOn("Blue")
			
			# Allow movement of cursor
			BattlefieldInfo.cursor.cursor_state = Cursor.PREP
		"Market":
			$"Prep Screen Control/Side Panel Text".text = MARKETPLACE_TEXT
		"Save":
			$"Prep Screen Control/Side Panel Text".text = SAVE

# Select song to play
func play_song(song_name):
	stop_music()
	if song_name == "A":
		$"Prep Theme A".play(0)
	else:
		$"Prep Theme B".play(0)

func start_battle():
	# Turn this off
	turn_off()
	
	# Disable
	BattlefieldInfo.cursor.emit_signal("turn_off_ui")
	BattlefieldInfo.cursor.disable_standard("standard")
	
	# Move Camera to where Eirika is
	BattlefieldInfo.main_game_camera.position = (BattlefieldInfo.Eirika.position + Vector2(-112, -82))
	BattlefieldInfo.main_game_camera.clampCameraPosition()
	BattlefieldInfo.cursor.position = BattlefieldInfo.Eirika.position
	BattlefieldInfo.cursor.updateCursorData()
	BattlefieldInfo.cursor.emit_signal("cursorMoved", "left", BattlefieldInfo.cursor.position)
	
	# Turn off with sound as well
	$Anim.play("Start Battle")
	yield($Anim, "animation_finished")
	stop_music()
	
	# Start level
	get_parent().start_battle()

# Stop music
func stop_music():
	if $"Prep Theme A".playing:
		$"Prep Theme A".stop()
	else:
		$"Prep Theme B".stop()

# Turn on this screen.
func turn_on():
	# Remove invisibility
	$Anim.play_backwards("Invi")
	
	# Wait until done
	yield($Anim, "animation_finished")
	
	# Allow movement
	set_process_input(true)

# Turn off this screen -> Move to the next screen
func turn_off():
	set_process_input(false)