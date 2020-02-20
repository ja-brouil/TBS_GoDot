extends Control

# Allows you to select units for battle
var max_units_select_possible = 6

# Array for all units selected
var units_selected = {}

# Current index
var current_index = 0

# String constants
var unit_number = "Units Selected [color=yellow]1/6[/color]"

# Node access
onready var unit_list = $"Unit List"
onready var number_of_units = $Number
onready var hand_selector = get_parent().get_node("Hand Selector")

func _ready():
	# Disable the scroll bar
	var scroll_bar = unit_list.get_v_scroll()
	scroll_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll_bar.modulate = Color(1,1,1,0)
	

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		pass

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
	
	# Allow input
	set_process_input(true)
	
	# Get focus
	unit_list.grab_focus()
	
	# Visible
	visible = true

# Exit
func exit():
	pass

# Set number text
func set_text():
	# Color
	if  units_selected.size() < max_units_select_possible:
		number_of_units.bbcode_text = str("[right]Units Selected [color=yellow]", units_selected.size() ,"/6[/color][/right]")
	elif  units_selected.size() == max_units_select_possible:
		number_of_units.bbcode_text = str("[right]Units Selected [color=#1ed214]",  units_selected.size() ,"/6[/color][/right]")
	elif  units_selected.size() > max_units_select_possible:
		number_of_units.bbcode_text = str("[right]Units Selected [color=red]",  units_selected.size() ,"/6[/color][/right]")

# Populate already selected units
func populate_selected_units():
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

# Reset
func reset():
	# Clear array
	units_selected.clear()
	
	# Clear the list
	unit_list.clear()
	
	# Reset current index
	current_index = 0

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
