extends Control

# Allows you to select units for battle
var max_units_select_possible = 6

# Array for all units selected
var units_selected = []

# Current index
var current_index = 0

# Node access
onready var unit_list = $"Unit List"

func _ready():
	# Disable the scroll bar
	var scroll_bar = unit_list.get_v_scroll()
	scroll_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll_bar.modulate = Color(1,1,1,0)
	
	# Get focus
	unit_list.select(0)
	unit_list.grab_focus()
	
	# Test
	start(ItemList.SELECT_MULTI)

func _input(event):
	pass

# Start
func start(select_mode_value):
	# Set type
	unit_list.select_mode = select_mode_value
	
	# Erase values
	reset()
	
	# Populate the units that are already selected
	populate_selected_units()
	
	# Allow input

# Exit
func exit():
	pass

# Populate already selected units
func populate_selected_units():
	# Get all the units in the y sort on the battlefield
	# For each of their ID, add them to the list
	# Find eirika and make sure she is NOT selectable
	for unit in range(unit_list.get_item_count()):
		if unit_list.get_item_text(unit) == "Eirika":
			unit_list.set_item_selectable(unit, false)
			units_selected.append(unit_list.get_item_text(unit))
			return
	# Add eirika to the list
	# Add whoever else per chapter needs to be in
	pass

# Reset
func reset():
	# Clear array
	units_selected.clear()
	
	# Clear the list
	# item_list.clear()
	
	# Reset current index
	current_index = 0



func _on_Unit_List_item_selected(index):
	# Is this Eirika?
	if unit_list.get_item_text(index) == "Eirika":
		unit_list.select(index)
