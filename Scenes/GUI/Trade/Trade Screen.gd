extends CanvasLayer

# Unit that can be traded with
var list_of_tradable_units = []
var current_unit_selected
var current_unit_selection_number = 0

# Input
var is_active = false

# Item slots
var item_slots_array = []

# Temp sprite
var temporary_sprite

# Menu Position
const X_OFF_SET = Vector2(5,0)
const OFF_SCREEN = Vector2(-150, -150)
const OFF_SET = Vector2(10,10)
const ACTION_SIZE_Y = 10

func _ready():
	# Slot initial
	reslot_item_array()

# Start this
func start():
	# Turn on
	$"Select Unit".visible = true
	
	# Reset slot
	list_of_tradable_units.clear()
	
	# Get all the units that are around
	for adj_cell in BattlefieldInfo.current_Unit_Selected.UnitMovementStats.currentTile.adjCells:
		if adj_cell.occupyingUnit != null && adj_cell.occupyingUnit.UnitMovementStats.is_ally:
			list_of_tradable_units.append(adj_cell.occupyingUnit)
	
	# Move everything off screen
	move_off_screen()
	
	# Reset selection
	current_unit_selection_number = 0
	current_unit_selected = list_of_tradable_units[current_unit_selection_number]
	build_menu(current_unit_selected)
	
	$"Timer".start(0)


# Build menu
func build_menu(unit):
	# Set position
	$"Select Unit".rect_position = Vector2(0,0)
	
	# Turn off cursor
	for unit in list_of_tradable_units:
		unit.get_node("Cursor Select").visible = false
	
	# Reslot
	reslot_item_array()
	
	# Move Off screen
	move_off_screen()
	
	# Replace the texture with the unit
	$"Select Unit/Top/Unit Portrait".texture = unit.unit_portrait_path
	
	# Replace the name 
	$"Select Unit/Top/Unit Name".text = unit.UnitStats.name
	
	# Move the first part
	$"Select Unit/Top".rect_position = Vector2(5,0)
	
	# Build the menu for each
	var last_item_slot = $"Select Unit/Top".rect_position.y + 7
	for item in unit.UnitInventory.inventory:
		# Pull item slot and set the correct data
		var item_slot = item_slots_array.pop_front()
		item_slot.position = Vector2(10, last_item_slot + ACTION_SIZE_Y - 1)
		item_slot.start(item)
		last_item_slot = item_slot.position.y
	
	# Put the bottom
	$"Select Unit/Bottom".rect_position = Vector2(10, last_item_slot + ACTION_SIZE_Y - 1)
	
	# Activate the cursor
	unit.get_node("Cursor Select").visible = true

func move_off_screen():
	$"Select Unit/Slot 1".position = OFF_SCREEN
	$"Select Unit/Slot 2".position = OFF_SCREEN
	$"Select Unit/Slot 3".position = OFF_SCREEN
	$"Select Unit/Slot 4".position = OFF_SCREEN
	$"Select Unit/Slot 5".position = OFF_SCREEN
	$"Select Unit/Slot 6".position = OFF_SCREEN

func reslot_item_array():
	item_slots_array.clear()
	# Set everything into the array slot
	item_slots_array.append($"Select Unit/Slot 1")
	item_slots_array.append($"Select Unit/Slot 2")
	item_slots_array.append($"Select Unit/Slot 3")
	item_slots_array.append($"Select Unit/Slot 4")
	item_slots_array.append($"Select Unit/Slot 5")
	item_slots_array.append($"Select Unit/Slot 6")

func _input(event):
	# No processing if not active
	if !is_active:
		return
	
	# Process Input
	if Input.is_action_just_pressed("ui_accept"):
		$"Hand Selector/Accept".play(0)
		process_selection()
	elif Input.is_action_just_pressed("ui_cancel"):
		$"Hand Selector/Cancel".play(0)
		go_back()
	elif Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_right"):
		current_unit_selection_number -= 1
		if current_unit_selection_number < 0:
			current_unit_selection_number = list_of_tradable_units.size() - 1
		current_unit_selected = list_of_tradable_units[current_unit_selection_number]
		$"Hand Selector/Move".play(0)
		build_menu(current_unit_selected)
	elif Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("ui_left"):
		current_unit_selection_number += 1
		if current_unit_selection_number >= list_of_tradable_units.size():
			current_unit_selection_number = 0
		current_unit_selected = list_of_tradable_units[current_unit_selection_number]
		$"Hand Selector/Move".play(0)
		build_menu(current_unit_selected)

# Head to trade screen
func process_selection():
	$"Trade Items Screen".start(current_unit_selected)
	turn_off()

# Turn off for trade
func turn_off():
	is_active = false
	
	# Turn visibility off
	$"Select Unit".visible = false
	
	# Turn extra cursors off
	for unit in list_of_tradable_units:
		unit.get_node("Cursor Select").visible = false

# Back to action selector
func go_back():
	turn_off()
	
	# Go back to action selector
	BattlefieldInfo.unit_movement_system.emit_signal("action_selector_screen")

func _on_Timer_timeout():
	is_active = true
