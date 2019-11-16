extends CanvasLayer

# Constants
const MARGIN_LEFT_OF_TOP = 3
const ACTION_SIZE_Y = 10

# Position
const TOP_LEFT = Vector2(12,20)
const TOP_RIGHT = Vector2(181,20)
const OFF_SIDE = Vector2(-100,-100)

# Hand
const HAND_OFF_SET = Vector2(-5,-1.5)

# Preload all the menu items
var node_array = ["Attack", "Item", "Heal", "Trade", "Wait"]

# Keep track of all the actions that we have currently
var current_actions = []
var current_number_action = 0
var current_option_selected = "Wait"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Test method for first item
	var test_array = [node_array[0], node_array[2], node_array[1], node_array[3] , node_array[4]]
	build_menu(test_array, TOP_LEFT)

# Start this screen
func start():
	pass

# Input for Hand movement
func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		print("FROM ACTION SELECTOR: This was called ", current_option_selected)
		$"Action Menu/Hand Selector/Accept".play(0)
	elif Input.is_action_just_pressed("ui_cancel"):
		print("FROM ACTION SELECTOR: WE ARE GOING BACK TO THE UNIT")
		$"Action Menu/Hand Selector/Cancel".play(0)
	elif Input.is_action_just_pressed("ui_up"):
		movement("up")
	elif Input.is_action_just_pressed("ui_down"):
		movement("down")

func movement(direction):
	match direction:
		"up":
			current_number_action -= 1
			if current_number_action < 0:
				current_number_action = 0
			else:
				$"Action Menu/Hand Selector".rect_position.y -= ACTION_SIZE_Y - 1
				$"Action Menu/Hand Selector/Move".play(0)
			current_option_selected = current_actions[current_number_action]
		"down":
			current_number_action += 1
			if current_number_action > current_actions.size() - 1:
				current_number_action = current_actions.size() - 1
			else:
				$"Action Menu/Hand Selector".rect_position.y += ACTION_SIZE_Y - 1
				$"Action Menu/Hand Selector/Move".play(0)
			current_option_selected = current_actions[current_number_action]


# Build the menu based on how many options there are
func build_menu(menu_items, position):
	# Show action menu
	$"Action Menu".visible = true
	
	# Move old items
	for child_nodes in $"Action Menu".get_children():
		child_nodes.rect_position = OFF_SIDE
	current_actions.clear()
	
	# Sort the array alphabetically
	menu_items.sort()
	
	# Put the top Item first -> Assume for now its top left for testing purposes
	$"Action Menu/Top".rect_position = position
	
#	Get each item and build the menu
	var last_item = $"Action Menu/Top"
	for menu_item in menu_items:
		get_node(str("Action Menu/",menu_item)).rect_position = Vector2($"Action Menu/Top".rect_position.x + MARGIN_LEFT_OF_TOP, last_item.rect_position.y + ACTION_SIZE_Y - 1)
		last_item = get_node(str("Action Menu/",menu_item))
		current_actions.append(menu_item)
	# Move bottom
	$"Action Menu/Bottom".rect_position = Vector2(last_item.rect_position.x, last_item.rect_position.y + ACTION_SIZE_Y - 1) 
	
	# Set the hand cursor to the first item in the list
	$"Action Menu/Hand Selector".rect_position = get_node(str("Action Menu/", current_actions[0])).rect_position + HAND_OFF_SET
	current_option_selected = current_actions[0]
	current_number_action = 0

# Move everything off and hide it
func hide_action_menu():
	$"Action Menu".visible = false
	
	# Move old items
	for child_nodes in $"Action Menu".get_children():
		child_nodes.rect_position = OFF_SIDE