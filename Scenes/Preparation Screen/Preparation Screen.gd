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

# Hand reset
var hand_default_position = Vector2(3.5, 58.0)
var hand_movement_vector= Vector2(0, 17)

# Test Level
var test_chapter = "res://Scenes/Battlefield/Chapter 4.tscn"

func _ready():
	set_process_input(false)
	
	# Test Debug mode
	start("3\nScourge of the Sea", "Kill enemy commanders", test_chapter)

func start(chapter_text, victory_text, path_to_next_level):
	# Start level
	var loaded_level = load(path_to_next_level)
	var next_level = loaded_level.instance()
	
	next_level.set_name("Current Level")
	next_level.visible = false
	
	# Add to tree
	get_parent().call_deferred("add_child", next_level)
	
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
	elif Input.is_action_just_pressed("ui_cancel"):
		turn_off()
		print("Heading to the map view!")
	elif Input.is_action_just_pressed("ui_accept"):
		process_selection()
		$"Prep Screen Control/Hand Selector/Accept".play(0)
		print("Selected process! Process: ", current_option)
	elif Input.is_action_just_pressed("start_battle"):
		$"Start Combat".play(0)
		print("Battle started!")
	elif Input.is_action_just_pressed("debug"):
		# Fade backward just for testing
		$Anim.play_backwards("Fade")
		yield($Anim, "animation_finished")
		start(" 4\nThe Grand Betrayal", "Escape the castle", test_chapter)
		play_song("A")

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
			$Anim.play("Invi")
			get_node("/root/Current Level").visible = true
			turn_off()
			BattlefieldInfo.main_game_camera.current = true
			BattlefieldInfo.cursor.cursor_state = Cursor.MOVE
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

# Stop music
func stop_music():
	if $"Prep Theme A".playing:
		$"Prep Theme A".stop()
	else:
		$"Prep Theme B".stop()

# Turn on this screen.
func turn_on():
	pass

# Turn off this screen -> Move to the next screen
func turn_off():
	set_process_input(false)
	
	# stop_music()