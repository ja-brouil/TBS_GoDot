extends Control

# Allows you to select units for battle
var max_units_select_possible = 6

# Array for all units selected
var units_selected = []

# Node access
onready var item_list = $"Unit List"

func _ready():
	# Disable the scroll bar
	var scroll_bar = item_list.get_v_scroll()
	scroll_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll_bar.modulate = Color(1,1,1,0)
	
	# Get focus
	item_list.select(0)
	item_list.grab_focus()

func _input(event):
	pass

# Start
func start(select_mode_value):
	# Set type
	item_list.select_mode = select_mode_value
	
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
	
	# Add eirika to the list
	# Add whoever else per chapter needs to be in
	pass

# Reset
func reset():
	# Clear array
	units_selected.clear()
	
	# Clear the list
	# item_list.clear()
