extends Control

# To swap
var first_item
var second_item
var temp_item

# First Unit
var ui_item_slots_1 = []
var item_slots_player_1 = []

# Second Unit
var second_unit
var ui_item_slots_2 = []
var item_slots_player_2 = []

# Cursor info
enum {LEFT, RIGHT}
var hand_position = LEFT
var slot_number = 0

# States
enum {NO_ITEM_SELECTED, ONE_ITEM_SELECTED}
var current_state = NO_ITEM_SELECTED

# Hand position
var original_hand_position = Vector2(3, 91)
var second_hand_position_off_screen = Vector2(-150, -150)
var inventory_x_difference = Vector2(132, 0)
var inventory_y_difference = Vector2(0, 10)

# Input
var is_active = false

func start(unit):
	# Set  Units and graphics
	second_unit = unit
	set_unit_portrait_and_name()
	
	# Reset to no unit selected
	current_state = NO_ITEM_SELECTED
	hand_position = LEFT
	slot_number = 0
	first_item = null
	second_item = null
	
	# Reset hand back to original spot
	$"Hand Selector 1".rect_position = original_hand_position
	$"Hand Selector 2".rect_position = second_hand_position_off_screen
	
	# Build Inventory
	build_inventory_menu()
	
	# Set first item to first item
	first_item = item_slots_player_1[slot_number]
	
	# Show everything
	visible = true
	
	# Start
	$Timer.start(0)


# Set graphics and name
func set_unit_portrait_and_name():
	# Current unit selected
	$"Unit Controlled by Player/Player 1".texture = BattlefieldInfo.current_Unit_Selected.unit_portrait_path
	$"Unit Controlled by Player/Player 1".flip_h = true
	
	# Player 1 name
	$"Unit Controlled by Player/Name BG/Name 1".text = BattlefieldInfo.current_Unit_Selected.UnitStats.name
	
	# Player 2 Portrait
	$"Unit Selected by Player/Player 2".texture = second_unit.unit_portrait_path
	
	# Player 2 name
	$"Unit Selected by Player/Name BG 2/Name 2".text = second_unit.UnitStats.name

# Build the inventory menu
func build_inventory_menu():
	# Reset slots
	reslot_arrays()
	
	# Current Unit Selected
	for item in BattlefieldInfo.current_Unit_Selected.UnitInventory.inventory:
		var item_slot = ui_item_slots_1.pop_front()
		item_slot.start(item)
		item_slots_player_1.append(item)
		
	# Do we have any extra slots?
	if !ui_item_slots_1.empty():
		while !ui_item_slots_1.empty():
			var item_slot = ui_item_slots_1.pop_front()
			item_slot.empty_slot()
			item_slots_player_1.append($Empty_Item)
	
	# Current Unit Selected
	for item2 in second_unit.UnitInventory.inventory:
		var item_slot = ui_item_slots_2.pop_front()
		item_slot.start(item2)
		item_slots_player_2.append(item2)
	
	# Do we have any extra slots?
	if !ui_item_slots_2.empty():
		while !ui_item_slots_2.empty():
			var item_slot = ui_item_slots_2.pop_front()
			item_slot.empty_slot()
			item_slots_player_2.append($Empty_Item)

func _input(event):
	if !is_active:
		return
	
	match current_state:
		NO_ITEM_SELECTED:
			if Input.is_action_just_pressed("ui_left"):
				# Are we on the RIGHT side?
				if hand_position == RIGHT:
					# Move cursor to the "left" side
					$"Hand Selector 1".rect_position -= inventory_x_difference
					$"Hand Selector 1/Move".play(0)
					# New Item Position
					first_item = item_slots_player_1[slot_number]
					hand_position = LEFT
			elif Input.is_action_just_pressed("ui_right"):
				# Are we on the LEFT side?
				if hand_position == LEFT:
					# Move cursor to the "left" side
					$"Hand Selector 1".rect_position += inventory_x_difference
					$"Hand Selector 1/Move".play(0)
					# New Item Position
					first_item = item_slots_player_1[slot_number]
					hand_position = RIGHT
			elif Input.is_action_just_pressed("ui_up"):
				if hand_position == RIGHT:
					# Move up cursor up and down ON THE RIGHT SIDE
					# Check if we are at the top
					if slot_number - 1 < 0:
						slot_number = 0
						first_item = item_slots_player_2[slot_number]
					else:
						slot_number -= 1
						$"Hand Selector 1".rect_position -= inventory_y_difference
						$"Hand Selector 1/Move".play(0)
						first_item = item_slots_player_2[slot_number]
				else:
					if slot_number - 1 < 0:
						slot_number = 0
						first_item = item_slots_player_1[slot_number]
					else:
						slot_number -= 1
						$"Hand Selector 1".rect_position -= inventory_y_difference
						$"Hand Selector 1/Move".play(0)
						first_item = item_slots_player_1[slot_number]
			elif Input.is_action_just_pressed("ui_down"):
				if hand_position == RIGHT:
					# Move up cursor up and down ON THE RIGHT SIDE
					# Check if we are at the top
					if slot_number + 1 > item_slots_player_2.size() - 1:
						slot_number = item_slots_player_2.size() - 1
						first_item = item_slots_player_2[slot_number]
					else:
						slot_number += 1
						$"Hand Selector 1".rect_position += inventory_y_difference
						$"Hand Selector 1/Move".play(0)
						first_item = item_slots_player_2[slot_number]
				else:
					if slot_number + 1 > item_slots_player_1.size() - 1:
						slot_number = item_slots_player_1.size() - 1
						first_item = item_slots_player_1[slot_number]
					else:
						slot_number += 1
						$"Hand Selector 1".rect_position += inventory_y_difference
						$"Hand Selector 1/Move".play(0)
						first_item = item_slots_player_1[slot_number]
			elif Input.is_action_just_pressed("ui_accept"):
				process_selection()
			elif Input.is_action_just_pressed("ui_cancel"):
				$"Hand Selector 1/Cancel".play(0)
				go_back() 
		ONE_ITEM_SELECTED:
			if Input.is_action_just_pressed("ui_up"):
				if hand_position == RIGHT:
					# Move up cursor up and down ON THE RIGHT SIDE
					# Check if we are at the top
					if slot_number - 1 < 0:
						slot_number = 0
						second_item = item_slots_player_2[slot_number]
					else:
						slot_number -= 1
						$"Hand Selector 1".rect_position -= inventory_y_difference
						$"Hand Selector 1/Move".play(0)
						second_item = item_slots_player_2[slot_number]
				else:
					if slot_number - 1 < 0:
						slot_number = 0
						second_item = item_slots_player_1[slot_number]
					else:
						slot_number -= 1
						$"Hand Selector 1".rect_position -= inventory_y_difference
						$"Hand Selector 1/Move".play(0)
						second_item = item_slots_player_1[slot_number]
			elif Input.is_action_just_pressed("ui_down"):
				if hand_position == RIGHT:
					# Move up cursor up and down ON THE RIGHT SIDE
					# Check if we are at the top
					if slot_number + 1 > item_slots_player_2.size() - 1:
						slot_number = item_slots_player_2.size() - 1
						second_item = item_slots_player_2[slot_number]
					else:
						slot_number += 1
						$"Hand Selector 1".rect_position += inventory_y_difference
						$"Hand Selector 1/Move".play(0)
						second_item = item_slots_player_2[slot_number]
				else:
					if slot_number + 1 > item_slots_player_1.size() - 1:
						slot_number = item_slots_player_1.size() - 1
						second_item = item_slots_player_1[slot_number]
					else:
						slot_number += 1
						$"Hand Selector 1".rect_position += inventory_y_difference
						$"Hand Selector 1/Move".play(0)
						second_item = item_slots_player_1[slot_number]
			elif Input.is_action_just_pressed("ui_accept"):
				process_selection()
			elif Input.is_action_just_pressed("ui_cancel"):
				# Move the second hand away
				$"Hand Selector 2".rect_position = Vector2(-150, -150)
				current_state = NO_ITEM_SELECTED
				second_item = null
				
				# Set First item
				if hand_position == RIGHT:
					first_item = item_slots_player_2[slot_number]
				else:
					first_item = item_slots_player_2[slot_number]
				
	if Input.is_action_just_pressed("debug"):
		print("SWAP SCREEN: FIRST ITEM: ", str(first_item), " SECOND ITEM: ", str(second_item))

func process_selection():
	match current_state:
		NO_ITEM_SELECTED:
			if hand_position == RIGHT:
				if first_item != $Empty_Item:
					first_item = item_slots_player_2[slot_number]
					current_state = ONE_ITEM_SELECTED
					
					# Set second hand position
					$"Hand Selector 2".rect_position = $"Hand Selector 1".rect_position
					
					# Move the hand to the left side
					$"Hand Selector 1".rect_position -= inventory_x_difference
					hand_position = LEFT
					
					# Set second item
					second_item = item_slots_player_1[slot_number]
					
					# Sound
					$"Hand Selector 1/Accept".play(0)
			else:
				if first_item != $Empty_Item:
					first_item = item_slots_player_1[slot_number]
					current_state = ONE_ITEM_SELECTED
					
					# Set second hand position
					$"Hand Selector 2".rect_position = $"Hand Selector 1".rect_position
					
					# Move the hand to the left side
					$"Hand Selector 1".rect_position += inventory_x_difference
					hand_position = RIGHT
					
					# Set second item
					second_item = item_slots_player_2[slot_number]
					
					# Sound
					$"Hand Selector 1/Accept".play(0)
		ONE_ITEM_SELECTED:
			# Are we on the left or right side
			if hand_position == LEFT:
				if second_item == $Empty_Item:
					# Just take this item out of the first one and send it to the second one
					second_unit.UnitInventory.remove_do_not_delete_item(first_item)
					BattlefieldInfo.current_Unit_Selected.UnitInventory.add_item(first_item)
					
					# We can continue to trade but we are done moving
					set_done()
					
				else:
					# Swap First Item
					second_unit.UnitInventory.remove_do_not_delete_item(first_item)
					BattlefieldInfo.current_Unit_Selected.UnitInventory.add_item(first_item)
					
					# Swap Second Item
					BattlefieldInfo.current_Unit_Selected.UnitInventory.remove_do_not_delete_item(second_item)
					second_unit.UnitInventory.add_item(second_item)
					
					# Done trading
					set_done()
			else:
				if second_item == $Empty_Item:
					# Just take this item out of the first one and send it to the second one
					BattlefieldInfo.current_Unit_Selected.UnitInventory.remove_do_not_delete_item(first_item)
					second_unit.UnitInventory.add_item(first_item)
					
					# We can continue to trade but we are done moving
					set_done()
				else:
					# Swap First Item
					BattlefieldInfo.current_Unit_Selected.UnitInventory.remove_do_not_delete_item(first_item)
					second_unit.UnitInventory.add_item(first_item)
					
					# Swap second item
					second_unit.UnitInventory.remove_do_not_delete_item(second_item)
					BattlefieldInfo.current_Unit_Selected.UnitInventory.add_item(second_item)
					
					# We can continue to trade but we are done moving
					set_done()

# Reslot the arrays
func reslot_arrays():
	ui_item_slots_1.clear()
	ui_item_slots_1.append($"Unit Controlled by Player/Inventory 1/Player 1 Slot 1")
	ui_item_slots_1.append($"Unit Controlled by Player/Inventory 1/Player 1 Slot 2")
	ui_item_slots_1.append($"Unit Controlled by Player/Inventory 1/Player 1 Slot 3")
	ui_item_slots_1.append($"Unit Controlled by Player/Inventory 1/Player 1 Slot 4")
	ui_item_slots_1.append($"Unit Controlled by Player/Inventory 1/Player 1 Slot 5")
	ui_item_slots_1.append($"Unit Controlled by Player/Inventory 1/Player 1 Slot 6")
	
	ui_item_slots_2.clear()
	ui_item_slots_2.append($"Unit Selected by Player/Inventory 2/Player 2 Slot 1")
	ui_item_slots_2.append($"Unit Selected by Player/Inventory 2/Player 2 Slot 2")
	ui_item_slots_2.append($"Unit Selected by Player/Inventory 2/Player 2 Slot 3")
	ui_item_slots_2.append($"Unit Selected by Player/Inventory 2/Player 2 Slot 4")
	ui_item_slots_2.append($"Unit Selected by Player/Inventory 2/Player 2 Slot 5")
	ui_item_slots_2.append($"Unit Selected by Player/Inventory 2/Player 2 Slot 6")
	
	item_slots_player_1.clear()
	item_slots_player_2.clear()

# Set Action to done
func set_done():
	# We can continue to trade but we are done moving
	BattlefieldInfo.current_Unit_Selected.UnitActionStatus.current_action_status = Unit_Action_Status.TRADE
	BattlefieldInfo.current_Unit_Selected.turn_greyscale_on()
	BattlefieldInfo.current_Unit_Selected.get_node("Animation").current_animation = "Idle"
	
	# Rebuild Menu
	is_active = false
	start(second_unit)

func go_back():
	# Hide
	visible = false
	
	# Turn off input
	is_active = false
	
	# Back to the Trade item screen
	get_parent().start()


func _on_Timer_timeout():
	is_active = true