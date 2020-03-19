extends Control

# Allows you to select units for battle
const max_units_select_possible = 8
var max_units_currently_number = 8

# Array for all units selected
var units_selected = {}

# State
enum UNIT_SELECTION_STATE {SELECT, EXCESS, LESS, OFF}
var current_state = UNIT_SELECTION_STATE.SELECT

# String constants
var unit_number = "Units Selected [color=yellow]1/6[/color]"

# UI Positions
const MESSAGE_BOX_POSITION = Vector2(62, 62)
const YES_HAND_POSITION = Vector2(12,55)
const NO_HAND_POSITION = Vector2(58, 56)
const OFF_SITE = Vector2(-300,-300)

# Yes No Choice Options
var current_yes_no_option = 0

# Node access
onready var unit_list = $"Unit List"
onready var number_of_units = $Number
onready var hand_selector = $"Yes No/Hand Selector"
onready var anim = $Anim

func _ready():
	# Disable the scroll bar
	var scroll_bar = unit_list.get_v_scroll()
	scroll_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll_bar.modulate = Color(1,1,1,0)
	
	# Disable input
	set_process_input(false)

func _input(event):
	match current_state:
		UNIT_SELECTION_STATE.SELECT:
			if Input.is_action_just_pressed("ui_cancel"):
				exit_check()
		UNIT_SELECTION_STATE.LESS:
			if Input.is_action_just_pressed("ui_left"):
				if current_yes_no_option - 1 == 0:
					current_yes_no_option = 0
					# Move hand
					hand_selector.get_node("Move").play()
					hand_selector.rect_position = YES_HAND_POSITION
			elif Input.is_action_just_pressed("ui_right"):
				if current_yes_no_option + 1 == 1:
					current_yes_no_option = 1
					# Move Hand
					hand_selector.get_node("Move").play()
					hand_selector.rect_position = NO_HAND_POSITION
			elif Input.is_action_just_pressed("ui_accept"):
				if current_yes_no_option == 0:
					$"Yes No".rect_position = OFF_SITE
					exit()
				else:
					# Move off sight
					$"Yes No".rect_position = OFF_SITE
					
					# Back to select
					current_state = UNIT_SELECTION_STATE.SELECT
					
					# Wait half a second to prevent some weird selection bug
					yield(get_tree().create_timer(0.3),"timeout")
					
					# Allow movement again
					unit_list.set_process_input(true)
					unit_list.focus_mode = Control.FOCUS_ALL
					unit_list.grab_focus()

		UNIT_SELECTION_STATE.EXCESS:
			# Show warning
			if Input.is_action_just_pressed("ui_accept") || Input.is_action_just_pressed("ui_cancel"):
				# Back to picking
				current_state = UNIT_SELECTION_STATE.SELECT
				
				# Move the not allowed
				hand_selector.get_node("Invalid").play()
				$"Too Many Units".rect_position = OFF_SITE
				
				# Wait half a second to prevent some weird selection bug
				yield(get_tree().create_timer(0.3),"timeout")
				
				# Allow movement again
				unit_list.set_process_input(true)
				unit_list.focus_mode = Control.FOCUS_ALL
				unit_list.grab_focus()
				
# Start
func start(select_mode_value):
	# Set type
	unit_list.select_mode = select_mode_value
	
	# Erase values
	reset()
	
	# Populate the units that are already selected
	populate_selected_units()
	
	# Set text
	set_text()
	
	# Play Anim
	anim.play("Fade")
	yield(anim, "animation_finished")
	
	# Allow input
	unit_list.focus_mode = Control.FOCUS_ALL
	unit_list.grab_focus()
	set_process_input(true)

# Run this before exiting
func exit_check():
	# Do we have too many units?
	if units_selected.size() < max_units_select_possible:
		# Stop unit list
		unit_list.set_process_input(false)
		unit_list.release_focus()
		unit_list.focus_mode = Control.FOCUS_NONE
		
		# Set to warning state
		current_state = UNIT_SELECTION_STATE.LESS
		
		# Set message
		$"Yes No/Warning Message".text = str("You have selected ", units_selected.size()," units out of ", max_units_select_possible ,". Proceed with this?")
		
		# Move the warning message and yes no
		$"Yes No".rect_position = MESSAGE_BOX_POSITION
		hand_selector.rect_position = YES_HAND_POSITION
		current_yes_no_option = 0
	elif units_selected.size() > max_units_select_possible:
		# Stop unit list
		unit_list.set_process_input(false)
		unit_list.release_focus()
		unit_list.focus_mode = Control.FOCUS_NONE
		
		# Set to not allowed state
		current_state = UNIT_SELECTION_STATE.EXCESS
		
		# Move the not allowed
		$"Too Many Units".rect_position = MESSAGE_BOX_POSITION
	else:
		exit()

# Place the allies on the map
func place_allies():
	# Max amount
	var current_amount_placed = 1
	
	# Clear the swap points
	for swap_point in BattlefieldInfo.swap_points:
		swap_point.occupyingUnit = null
	
	# Merge the arrays
	for ally_unit in BattlefieldInfo.ally_units_not_in_battle.values():
		if !BattlefieldInfo.ally_units.has(ally_unit.UnitStats.identifier):
			BattlefieldInfo.ally_units[ally_unit.UnitStats.identifier] = ally_unit
	
	# Clear the old array
	BattlefieldInfo.ally_units_not_in_battle.clear()
	
	# Reset all the unit tiles
	for ally_unit in BattlefieldInfo.ally_units.values():
		if ally_unit == BattlefieldInfo.ally_units["Eirika"]:
			continue
		else:
			ally_unit.UnitMovementStats.currentTile = null
			ally_unit.position = Vector2(-500, -500)
	
	# Place new positions
	for ally_unit in units_selected.values():
		if current_amount_placed <= max_units_currently_number:
			if BattlefieldInfo.ally_units[ally_unit].UnitMovementStats.currentTile == null:
				for swap_point in BattlefieldInfo.swap_points:
					if swap_point.occupyingUnit == null:
						BattlefieldInfo.ally_units[ally_unit].position = swap_point.position
						BattlefieldInfo.ally_units[ally_unit].UnitMovementStats.currentTile = swap_point
						swap_point.occupyingUnit = BattlefieldInfo.ally_units[ally_unit]
						current_amount_placed += 1
						break
	
	# Move any units that don't have current tiles off in the battlefield info
	for ally_unit in BattlefieldInfo.ally_units.values():
		if ally_unit.UnitMovementStats.currentTile == null:
			# Move them off
			BattlefieldInfo.ally_units_not_in_battle[ally_unit.UnitStats.identifier] = ally_unit
			
			# Remove them from the array
			BattlefieldInfo.ally_units.erase(ally_unit.UnitStats.identifier)

# Exit
func exit():
	# Set to select
	current_state = UNIT_SELECTION_STATE.OFF
	
	# Set the units that are selected into the spawn points
	# Remove Eirika
	units_selected.erase("Eirika")
	
	# Place the rest of the units
	place_allies()
	
	# Exit out of this
	unit_list.set_process_input(false)
	set_process_input(false)
	
	# Deselect everything
	unit_list.unselect_all()
	unit_list.release_focus()
	
	# Play anim backward
	anim.play_backwards("Fade")
	yield(anim, "animation_finished")
	
	# Start Prep screen again
	BattlefieldInfo.preparation_screen.turn_on_without_anim()


# Set number text
func set_text():
	# Color
	if units_selected.size() < max_units_select_possible:
		number_of_units.bbcode_text = str("[right]Units Selected [color=yellow]", units_selected.size() ,"/", max_units_select_possible,"[/color][/right]")
	elif  units_selected.size() == max_units_select_possible:
		number_of_units.bbcode_text = str("[right]Units Selected [color=#1ed214]",  units_selected.size() ,"/", max_units_select_possible,"[/color][/right]")
	elif  units_selected.size() > max_units_select_possible:
		number_of_units.bbcode_text = str("[right]Units Selected [color=red]",  units_selected.size() ,"/", max_units_select_possible,"[/color][/right]")

# Populate already selected units
func populate_selected_units():
	# Merge the arrays
	for ally_unit in BattlefieldInfo.ally_units_not_in_battle.values():
		if !BattlefieldInfo.ally_units.has(ally_unit.UnitStats.identifier):
			BattlefieldInfo.ally_units[ally_unit.UnitStats.identifier] = ally_unit
	
	# Get all the units in the y sort on the battlefield
	# For each of their ID, add them to the list
	for ally_unit in BattlefieldInfo.ally_units.values():
		unit_list.add_item(ally_unit.UnitStats.name, ally_unit.unit_portrait_path, true)
		
	# Find eirika and make sure she is NOT selectable
	for unit in range(unit_list.get_item_count()):
		if unit_list.get_item_text(unit) == "Eirika":
			unit_list.select(unit)
			unit_list.set_item_disabled(unit, true)
			unit_list.set_item_custom_fg_color(unit, Color(0.12, 0.82, 0.08, 1))
			units_selected[unit_list.get_item_text(unit)] = unit_list.get_item_text(unit)
	
	# Highlight all units that are already on the prep spawn squares
	for tile in BattlefieldInfo.swap_points:
		if tile.occupyingUnit:
			var unit_name = tile.occupyingUnit.UnitStats.name
			for unit_listing in range(unit_list.get_item_count()):
				if unit_name == unit_list.get_item_text(unit_listing):
					unit_list.select(unit_listing, false)
					units_selected[unit_list.get_item_text(unit_listing)] = unit_list.get_item_text(unit_listing)

# Reset
func reset():
	# Clear array
	units_selected.clear()
	
	# Clear the list
	unit_list.clear()
	
	# Move off site
	$"Yes No".rect_position = OFF_SITE
	$"Too Many Units".rect_position = OFF_SITE
	
	# Yes no choice
	current_yes_no_option = 0
	
	# Reset the max amount
	max_units_currently_number = 8
	
	# Current State
	current_state = UNIT_SELECTION_STATE.SELECT

func _on_Unit_List_multi_selected(index, selected):
	if selected:
		if unit_list.get_item_text(index) != "Eirika":
			units_selected[unit_list.get_item_text(index)] = unit_list.get_item_text(index)
			hand_selector.get_node("Accept").play()
	else:
		if unit_list.get_item_text(index) != "Eirika":
			units_selected.erase(unit_list.get_item_text(index))
			hand_selector.get_node("Cancel").play()
	set_text()
