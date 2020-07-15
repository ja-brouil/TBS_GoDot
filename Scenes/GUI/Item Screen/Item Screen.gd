extends CanvasLayer

# Constants
const MARGIN_LEFT_OF_TOP = 3
const ACTION_SIZE_Y = 10

# Position
const TOP_LEFT = Vector2(12,20)
const OFF_SIDE = Vector2(-100,-100)
const MUGSHOT_POSITION = Vector2(145,22)
const EQUIP_BOX_LOCATION = Vector2(80,20)

# Item slots
var item_slot_array = []

# Hand
const HAND_OFF_SET = Vector2(-11,-1.5)

# Signals for changing UI screens
signal selected_wait
signal selected_back

# UI Active
var is_active = false

# For damage preview screen
signal menu_moved

# Keep track of all the actions that we have currently
var current_items = []
var current_number_action = 0
var current_option_selected

func _ready():
	add_item_back_to_array()

# Start this screen
func start():
	# Show action menu
	$"Item Menu".rect_position = Vector2(0,0)
	
	# Build Menu
	build_menu()
	
	# Start input acceptance
	$Timer.start(0)

# Input for Hand movement
func _input(event):
	if !is_active:
		return
		
	if Input.is_action_just_pressed("ui_accept"):
		$"Item Menu/Hand Selector/Accept".play(0)
		process_selection()
	elif Input.is_action_just_pressed("ui_cancel"):
		$"Item Menu/Hand Selector/Cancel".play(0)
		go_back()
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
				$"Item Menu/Hand Selector".rect_position.y -= ACTION_SIZE_Y - 1
				$"Item Menu/Hand Selector/Move".play(0)
			current_option_selected = current_items[current_number_action]
			set_item_stats(current_items[current_number_action])
		"down":
			current_number_action += 1
			if current_number_action > current_items.size() - 1:
				current_number_action = current_items.size() - 1
			else:
				$"Item Menu/Hand Selector".rect_position.y += ACTION_SIZE_Y - 1
				$"Item Menu/Hand Selector/Move".play(0)
			current_option_selected = current_items[current_number_action]
			set_item_stats(current_items[current_number_action])

func add_item_back_to_array():
	current_items.clear()
	item_slot_array.clear()
	item_slot_array.append($"Item Menu/Slot 1")
	item_slot_array.append($"Item Menu/Slot 2")
	item_slot_array.append($"Item Menu/Slot 3")
	item_slot_array.append($"Item Menu/Slot 4")
	item_slot_array.append($"Item Menu/Slot 5")
	item_slot_array.append($"Item Menu/Slot 6")

func process_selection():
	$"Item Menu/Equip Discord Box".start(current_option_selected)
	is_active = false

# Build the menu based on how many options there are
func build_menu():
	# Repopulate the array
	add_item_back_to_array()
	
	# Move old items
	$"Item Menu/Bottom".position = OFF_SIDE
	for item_slot in item_slot_array:
		item_slot.position = OFF_SIDE
	current_items.clear()
	
	# Move Box
	$"Item Menu/Equip Discord Box".rect_position = EQUIP_BOX_LOCATION
	
	# Mugshot
	$"Item Menu/Mugshot".texture = BattlefieldInfo.current_Unit_Selected.unit_mugshot
	$"Item Menu/Mugshot".rect_position = MUGSHOT_POSITION
	
#	Get each item and build the menu
	var last_item = item_slot_array.front()
	last_item.position = TOP_LEFT
	var first_item = item_slot_array.front()
	for items in BattlefieldInfo.current_Unit_Selected.UnitInventory.inventory:
		# Pull item slot and set the correct data
		var item_slot = item_slot_array.pop_front()
		item_slot.position = Vector2(TOP_LEFT.x + MARGIN_LEFT_OF_TOP, last_item.position.y + ACTION_SIZE_Y - 1)
		item_slot.start(items)
		last_item = item_slot
		current_items.append(items)
	# Move bottom
	$"Item Menu/Bottom".position = Vector2(57.5, last_item.position.y + ACTION_SIZE_Y) 
	
	# Move top
	$"Item Menu/Top".position = Vector2(56,26)
	
	# Set the hand cursor to the first item in the list
	$"Item Menu/Hand Selector".rect_position = first_item.position + HAND_OFF_SET
	current_number_action = 0
	current_option_selected = current_items[current_number_action]
	
	# Set item stats
	set_item_stats(current_items[0])

func go_back():
	# Turn off input
	is_active = false
	
	# Move everything off
	$"Item Menu".rect_position = Vector2(-300, -300)
	
	# Go back to action selector
	BattlefieldInfo.unit_movement_system.emit_signal("action_selector_screen")

func set_item_stats(item):
	# Set the stats for the selected item
	$"Item Menu/Mugshot/Item Stats/Background/Weapon Name".text = item.item_name
	$"Item Menu/Mugshot/Item Stats/Background/Uses Amount".text = str(item.uses)
	$"Item Menu/Mugshot/Item Stats/Background/Power Amt".text = str(item.might)
	$"Item Menu/Mugshot/Item Stats/Background/Crit Amt".text = str(item.crit)
	$"Item Menu/Mugshot/Item Stats/Background/Hit Amt".text = str(item.hit)
	
	# Set icon
	$"Item Menu/Mugshot/Item Stats/Background/TextureRect2".texture = item.icon
	
	# Green color
	if BattlefieldInfo.current_Unit_Selected.UnitInventory.current_item_equipped == item:
		$"Item Menu/Mugshot/Item Stats/Background/anim".play("equipped")
	else:
		$"Item Menu/Mugshot/Item Stats/Background/anim".stop(true)
		$"Item Menu/Mugshot/Item Stats/Background/Weapon Name".set("custom_colors/font_color", Color(1.0, 1.0, 1.0))

func _on_Timer_timeout():
	# Active Input
	is_active = true
