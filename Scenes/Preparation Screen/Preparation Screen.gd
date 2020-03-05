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

# Current song
var current_song

# Hand reset
var hand_default_position = Vector2(3.5, 58.0)
var hand_movement_vector= Vector2(0, 17)

func _ready():
	set_process_input(false)
	
	# Set self
	BattlefieldInfo.preparation_screen = self
	
	# Test
	# start("Test Title Chapter", BattlefieldInfo.victory_text, "res://Scenes/Intro Screen/Intro Screen.tscn", "A")

func start(chapter_text, victory_text, path_to_next_level, prep_song):\
	# Remove intro screen if it's still there
	if get_tree().get_root().has_node("Intro Screen"):
		get_tree().get_root().get_node("Intro Screen").queue_free()
	
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
					break
	
	# Heal Units and reset
	for ally_unit in BattlefieldInfo.ally_units.values():
		ally_unit.UnitStats.current_health = ally_unit.UnitStats.max_health
		ally_unit.UnitActionStatus.set_current_action(Unit_Action_Status.MOVE)
		ally_unit.turn_greyscale_off()
	
	# Play Music
	current_song = prep_song
	play_song(prep_song)
	
	# Set Text
	$"Prep Screen Control/Chapter Title Background/Chapter Title".text = str("Chapter ", chapter_text)
	$"Prep Screen Control/Victory Condition".text = victory_text
	
	# Reset Hand
	$"Prep Screen Control/Hand Selector".rect_position = hand_default_position
	
	# Reset option
	current_option_number = 0
	current_option = all_options_array[current_option_number]
	
	# Set turn number back to 1
	BattlefieldInfo.turn_manager.player_turn_number = 1
	BattlefieldInfo.turn_manager.enemy_turn_number = 1
	
	# Fade and allow input
	$"Prep Screen Control".visible = true
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
			$"Prep Screen Control/Unit Select".start(ItemList.SELECT_MULTI)
			$"Prep Screen Control/Unit Select".visible = true
			
			# Temp Disable this
			temp_disable()
		"Inventory":
			$"Prep Screen Control/Side Panel Text".text = INVENTORY_TEXT
		"Map":
			# Make this go invisible
			$Anim.play("Invi")
			
			# Prevent clicks right away
			yield($Anim,"animation_finished")
			
			# Turn this off
			turn_off()
			
			# Turn on UI
			BattlefieldInfo.battlefield_ui.get_node("Battlefield HUD").visible = true
			
			# Set Camera
			BattlefieldInfo.main_game_camera.current = true
			
			# Turn on the blue tiles
			for blueTile in BattlefieldInfo.swap_points:
				blueTile.get_node("MovementRangeRect").turnOn("Blue")
			
			# Allow movement of cursor
			BattlefieldInfo.cursor.cursor_state = Cursor.PREP
		"Market":
			# Go to the shop
			$"Prep Screen Control/Side Panel Text".text = MARKETPLACE_TEXT
			
			# Hide this
			$Anim.play_backwards("Fade Fast")
			yield($Anim, "animation_finished")
			$Shop.start(Shop_UI.SHOP_STATE.BUY)
			$"Prep Screen Control".visible = false
			
			# Hide Battlefield info UI
			BattlefieldInfo.battlefield_ui.get_node("Battlefield HUD").visible = false
			
			# Pause music
			stop_music()
			
			# Temp Disable this
			temp_disable()
		"Save":
			$"Prep Screen Control/Side Panel Text".text = "Game Saved!"
			yield(get_tree().create_timer(0.5), "timeout")
			$"Prep Screen Control/Side Panel Text".text = SAVE
			BattlefieldInfo.save_load_system.save_game()
			

# Select song to play
func play_song(song_name):
	stop_music()
	if song_name == "A":
		$"Prep Theme A".volume_db = 0
		$"Prep Theme A".play(0)
	else:
		$"Prep Theme B".volume_db = 0
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
	BattlefieldInfo.level_container.start_battle()

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
	
	$"Prep Screen Control/Hand Selector".visible = true
	
	# Wait until done
	yield($Anim, "animation_finished")
	
	# Allow movement
	set_process_input(true)

func turn_on_fade():
	$Anim.play("Fade Fast")
	$"Prep Screen Control/Hand Selector".visible = true
	$"Prep Screen Control".visible = true
	
	# Wait until done
	yield($Anim, "animation_finished")
	
	
	# Allow movement
	set_process_input(true)

func temp_disable():
	$"Prep Screen Control/Hand Selector".visible = false
	set_process_input(false)

func turn_on_without_anim():
	set_process_input(true)
	
	$"Prep Screen Control/Hand Selector".visible = true

# Turn off this screen -> Move to the next screen
func turn_off():
	set_process_input(false)
