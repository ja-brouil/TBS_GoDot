extends CanvasLayer

# To do later just write down what's needed to be done

# Constants 
const OFF_SET = Vector2(-100, -100)

# Input
var is_active = false

# List
var item_list_menu = []
var current_selected_number = 0
var current_selected_option = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called when this UI comes into play
func start():
	pass

# Process input
func _input(event):
	if !is_active:
		return


# Get enemies available with weapons available
func get_all_enemies_available():
	pass

# Build Item List
func build_item_list():
	pass

# Change the item box window whenever the cursor moves
func update_item_box():
	pass

# Cancel option
func go_back():
	pass

# Go to unit selection
func process_selection():
	pass

# On/Off
func turn_on():
	$"Weapon Select".visible = true
	is_active = true

func turn_off():
	$"Weapon Select".visible = false
	is_active = false