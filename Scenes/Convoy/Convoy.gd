extends Node2D

# Convoy is the inventory system for storing extra items
# Item selected
var current_item_selected_index = 0

# Unit selected
var current_unit_selected = null

# Current list selected
var previous_list_selected_index = 0
var current_list_selected_index = 0

# Positioning
const LIST_POSITION = Vector2(128, 6)

# UI Status
enum CONVOY_STATUS {SELECT_UNIT, PASS_ITEM_TO_UNIT, SELECT_ITEM, OFF, SELL_ITEM, CONFIRM_SELL, ASK, DEPOSIT, CONFIRM_DEPOSIT}
var current_convoy_status

# Icon for unit picker -> Change later for real icon
var icon = preload("res://FE Icon.jpg")

# Node access
onready var sword_list = $"All Lists/Sword"
onready var lance_list = $"All Lists/Lance"
onready var axe_list = $"All Lists/Axe"
onready var bow_list = $"All Lists/Bow"
onready var tome_list = $"All Lists/Tome"
onready var heal_list = $"All Lists/Heal"
onready var consumable_list = $"All Lists/Consumable"
onready var item_stats_label = $"Item Stats"
onready var unit_picker = $"Unit Picker Solo"
onready var unit_inventory = $"Unit Inventory Display"

# Store all the nodes into this array for controlled access
var all_lists_array = []


# Background list
var background_index = 0
var all_backgrounds = [
	preload("res://assets/backgrounds/FE BG 1.png"),
	preload("res://assets/backgrounds/FE BG 2.jpg"),
	preload("res://assets/backgrounds/FE BG 3.jpg"),
	preload("res://assets/backgrounds/FE BG 4.jpg"),
	preload("res://assets/backgrounds/FE BG 5.jpg")
]

func _ready():
	# Set appropriate strings
	sword_list.set_text("Swords")
	lance_list.set_text("Lances")
	axe_list.set_text("Axes")
	bow_list.set_text("Bow")
	tome_list.set_text("Tomes")
	heal_list.set_text("Healing Staves")
	consumable_list.set_text("Consumables")
	
	# Disable input
	set_process_input(false)
	
	# Set convoy
	BattlefieldInfo.convoy = self
	
	# DEBUG
	# test()

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		pass
	elif Input.is_action_just_pressed("ui_down"):
		pass
	elif Input.is_action_just_pressed("ui_left"):
		# Do not process if not in item select mode
		if current_convoy_status == CONVOY_STATUS.SELECT_UNIT || current_convoy_status == CONVOY_STATUS.DEPOSIT:
			return
		
		# Do nothing if goes underneath 0
		if current_list_selected_index - 1 < 0:
			return
		
		# Set new numbers
		previous_list_selected_index = current_list_selected_index
		current_list_selected_index -= 1
		
		# Set the next list
		next_list(all_lists_array[previous_list_selected_index],all_lists_array[current_list_selected_index])
		
		# Play Sound
		$"Hand Selector/Move2".play(0)
		
	elif Input.is_action_just_pressed("ui_right"):
		# Do not process if not in item select mode
		if current_convoy_status == CONVOY_STATUS.SELECT_UNIT || current_convoy_status == CONVOY_STATUS.DEPOSIT:
			return
		
		# Do nothing if goes above the size of the array
		if current_list_selected_index + 1 > all_lists_array.size() - 1:
			return
		
		# Set new numbers
		previous_list_selected_index = current_list_selected_index
		current_list_selected_index += 1
		
		# Set the next list
		next_list(all_lists_array[previous_list_selected_index], all_lists_array[current_list_selected_index])
		
		# Play Sound
		$"Hand Selector/Move2".play(0)
		
	elif Input.is_action_just_pressed("ui_accept"):
		process_accept()
	elif Input.is_action_just_pressed("ui_cancel"):
		process_cancel()
	elif Input.is_action_just_pressed("R button"):
		swap_btn_current_unit_and_convoy()

# Start the convoy
func start():
	# Set to swords
	current_list_selected_index = 0
	
	# Reset tracking variables
	current_item_selected_index = 0
	
	# Set all lists into the array
	all_lists_array.append(sword_list)
	all_lists_array.append(lance_list)
	all_lists_array.append(axe_list)
	all_lists_array.append(bow_list)
	all_lists_array.append(tome_list)
	all_lists_array.append(heal_list)
	all_lists_array.append(consumable_list)
	
	# Start first list
	deactivate_all_lists()
	activate_list(all_lists_array[current_list_selected_index])
	
	# Set new text
	unit_picker.set_new_text_instructions("Select a unit to receive this item.")
	change_text("Convoy")
	
	# Set to select item
	current_convoy_status = CONVOY_STATUS.SELECT_ITEM
	
	# Turn off all units
	Calculators.turn_off_all_units()
	
	# Make Visible
	visible = true
	
	# Play the animation
	$AnimationPlayer.play("Fade")
	yield($"AnimationPlayer", "animation_finished")
	
	# Allow movement
	set_process_input(true)

func start_on_sell():
	start()
	current_convoy_status = CONVOY_STATUS.SELL_ITEM
	change_text("Select Item to Sell")
	

func start_with_unit_selected(unit):
	# Set unit selected
	current_unit_selected = unit
	
	# Start the unit inventory display if we have a unit already selected
	unit_inventory.start(current_unit_selected)
	
	# Start the node
	start()

# Add an item to the convoy
func add_item_to_convoy(item):
	item._ready()
	# If the item is a consumable, put it in the consumable list
	if item.item_class == Item.ITEM_CLASS.CONSUMABLE:
		consumable_list.add_item(item)
	else:
		# Place weapon in correct location
		match item.weapon_type:
			Item.WEAPON_TYPE.SWORD:
				sword_list.add_item(item)
			Item.WEAPON_TYPE.AXE:
				axe_list.add_item(item)
			Item.WEAPON_TYPE.LANCE:
				lance_list.add_item(item)
			Item.WEAPON_TYPE.BOW:
				bow_list.add_item(item)
			Item.WEAPON_TYPE.LIGHT, Item.WEAPON_TYPE.DARK, Item.WEAPON_TYPE.ELEMENTAL:
				tome_list.add_item(item)
			Item.WEAPON_TYPE.HEALING:
				heal_list.add_item(item)

func next_list(previous_list, next_list):
	deactivate_list(previous_list)
	activate_list(next_list)

func activate_list(list):
	list.start(self)

func deactivate_list_no_hide(list, var reset_index = true):
	list.disable_input()
	
	# Set new index
	if (reset_index):
		current_item_selected_index = 0

func deactivate_list(list, var reset_index = true):
	# Stop process
	list.exit()
	
	# Set new index
	if (reset_index):
		current_item_selected_index = 0

func deactivate_all_lists():
	for list in all_lists_array:
		deactivate_list(list)

func deactivate_all_lists_no_hide():
	for list in all_lists_array:
		deactivate_list_no_hide(list)

func exit():
	# Deactivate all list
	deactivate_all_lists()
	
	# Turn off
	set_process_input(false)
	
	# Go back
	# If Unit is not null, then we know we are in the battlefield
	if current_unit_selected != null:
		BattlefieldInfo.unit_movement_system.emit_signal("action_selector_screen")
	
	# Always remove the current unit
	current_unit_selected = null
	
	# Play the animation
	$AnimationPlayer.play_backwards("Fade")
	yield($"AnimationPlayer", "animation_finished")
	visible = false
	
	# Turn units back on
	Calculators.turn_on_all_units()

func test():
	# Swords
	sword_list.add_item(load(ALL_ITEMS_REF.all_items["Iron Sword"]).instance())
	sword_list.add_item(load(ALL_ITEMS_REF.all_items["Iron Sword"]).instance())
	sword_list.add_item(load(ALL_ITEMS_REF.all_items["Killing Edge"]).instance())
	
	# Axe
	axe_list.add_item(load(ALL_ITEMS_REF.all_items["Iron Axe"]).instance())
	axe_list.add_item(load(ALL_ITEMS_REF.all_items["Iron Axe"]).instance())
	axe_list.add_item(load(ALL_ITEMS_REF.all_items["Iron Axe"]).instance())
	axe_list.add_item(load(ALL_ITEMS_REF.all_items["Iron Axe"]).instance())
	
	# Modify the axes a little bit
	axe_list.item_list[1].uses = 5
	axe_list.item_list[1].crit = 15
	axe_list.item_list[2].uses = 32
	axe_list.item_list[3].max_range = 4
	
	# Lance
	# Nothing, as a test
	
	# No Heal but put tomes
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	

func item_text_reset():
	item_stats_label.text = "Item Stats"

func process_accept():
	match current_convoy_status:
		CONVOY_STATUS.SELECT_ITEM:
			# Is the current list empty
			if all_lists_array[current_list_selected_index].item_list.size() == 0:
				return
			
			# Play hand sound
			$"Hand Selector/Accept".play(0)
			
			# Are we in the preparation mode or are we on the battlefield?
			if current_unit_selected != null:
				# Check if the inventory is full and reject if it is
				if current_unit_selected.UnitInventory.inventory.size() == Unit_Inventory.MAX_INVENTORY:
					# Set text of convoy label
					change_text("This unit's inventory is full!")
					
					# Play can't sound
					$"All Lists/Axe/Hand Selector/Invalid".play(0)
					set_process_input(false)
					
					# Wait 1 second
					yield(get_tree().create_timer(1), "timeout")
					set_process_input(true)
					change_text("Select Item or Deposit")
					return
				
				item_stats_label.hide()
				
				current_convoy_status = CONVOY_STATUS.PASS_ITEM_TO_UNIT
				
				# Start the yes no box
				$"Yes No Box Generic".start()
				$"ColorRect/Convoy Label".text = "Send this item?"
				deactivate_list_no_hide(all_lists_array[current_list_selected_index])
				set_process_input(false)
			else:
				# Set new state
				current_convoy_status = CONVOY_STATUS.SELECT_UNIT
				
				item_stats_label.hide()
				
				# Start the unit picker
				unit_picker.start()
				
				# Stop input on the main input
				deactivate_list(all_lists_array[current_list_selected_index], false)
		# We are in the preparation screen
		CONVOY_STATUS.SELECT_UNIT:
			# Pass the unit the new unit
			# Check if there is space in the inventory.
			if unit_picker.unit_selected.UnitInventory.inventory.size() == Unit_Inventory.MAX_INVENTORY:
				# Display new message and turn off accept for a minute
				unit_picker.set_new_text_instructions("This unit's inventory is full!")
				
				# Play can't sound
				$"All Lists/Axe/Hand Selector/Invalid".play(0)
				
				# Wait 0.4 seconds
				yield(get_tree().create_timer(1), "timeout")
				
				# Set text back
				unit_picker.set_new_text_instructions("Select a unit to receive this item.")
			else:
				# Set text
				unit_picker.set_new_text_instructions("Select a unit to receive this item.")
				
				# Send item to unit
				send_item_to_unit(unit_picker.unit_selected)
				
				# Hide unit picker
				unit_picker.exit()
				
		# On the battlefield and we only want to pass to one unit
		CONVOY_STATUS.PASS_ITEM_TO_UNIT:
			pass
		CONVOY_STATUS.SELL_ITEM:
			# Is the current list empty
			if all_lists_array[current_list_selected_index].item_list.size() == 0:
				return
			
			# Play hand sound
			$"Hand Selector/Accept".play(0)
			
			# Hide item stats
			item_stats_label.hide()
			
			# Set convoy status to confirm
			current_convoy_status = CONVOY_STATUS.CONFIRM_SELL
			
			# Deactivate the lists first
			deactivate_list_no_hide(all_lists_array[current_list_selected_index], false)
			
			# Change Text
			change_text(str("Sell ", all_lists_array[current_list_selected_index].get_item_selected().item_name ,"?"))
			
			# Show yes/no box
			$"Yes No Box Generic".start()
			
			# Stop input
			set_process_input(false)
		CONVOY_STATUS.DEPOSIT:
			change_text("Deposit this item?")
			
			# Show yes/no box
			$"Yes No Box Generic".start()
			
			# Set new state
			current_convoy_status = CONVOY_STATUS.CONFIRM_DEPOSIT
			
			# Stop the input in the unit inventory
			$"Unit Inventory Display".disallow_input()
			
			# Stop input
			set_process_input(false)

func process_cancel():
	match current_convoy_status:
		CONVOY_STATUS.SELECT_UNIT:
			# Previous state
			current_convoy_status = CONVOY_STATUS.SELECT_ITEM
			
			# Play cancel sound
			$"Hand Selector/Cancel".play(0)
			
			# Show item stats
			item_stats_label.show()
			
			# Hide unit picker
			unit_picker.exit()
			
			# Activate the current list
			activate_list(all_lists_array[current_list_selected_index])
			# set_process_input(true)
		# If here, we are exiting
		CONVOY_STATUS.SELECT_ITEM:
			# Exit
			exit()
		# If here, we are selling from the convoy in a shop
		CONVOY_STATUS.SELL_ITEM:
			# Exit and go back to the shop
			BattlefieldInfo.preparation_screen.get_node("Shop/Unit Picker Solo").start_with_convoy()
			exit()
			BattlefieldInfo.preparation_screen.get_node("Shop").set_input_timer(true)
		CONVOY_STATUS.DEPOSIT:
			set_process_input(true)
			# Deactivate Unit Inventory display
			$"Unit Inventory Display".disallow_input()
			
			# Activate list again
			activate_list(all_lists_array[current_list_selected_index])
			
			# Set new text
			change_text("Select Item to withdraw")
			
			# Set new status
			current_convoy_status = CONVOY_STATUS.SELECT_ITEM
			set_process_input(true)

# Send item to unit
func send_item_to_unit(unit_to_receive_item):
	# Set as User done if you pull an item
	if current_unit_selected != null:
		BattlefieldInfo.current_Unit_Selected.UnitActionStatus.current_action_status = Unit_Action_Status.TRADE
		BattlefieldInfo.current_Unit_Selected.turn_greyscale_on()
		BattlefieldInfo.current_Unit_Selected.get_node("Animation").current_animation = "Idle"
	
	# Get the item to transfer
	var item_to_transfer = all_lists_array[current_list_selected_index].transfer_item()
	
	# Change text at the top
	$"ColorRect/Convoy Label".text = str("Sent ", item_to_transfer.item_name ," from convoy to ", unit_to_receive_item.UnitStats.name ,"!")
	
	# Move the item to the unit's inventory
	unit_to_receive_item.UnitInventory.add_item(item_to_transfer)
	
	# Sleep 0.5 seconds
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Set convoy label back
	$"ColorRect/Convoy Label".text = "Convoy"
	
	# Back to convoy
	current_convoy_status = CONVOY_STATUS.SELECT_ITEM
	
	# Show Item stats
	item_stats_label.show()
	
	# Activate the current list
	activate_list(all_lists_array[current_list_selected_index])

# Change the text at the top
func change_text(new_text):
	$"ColorRect/Convoy Label".text = new_text

# Swap between the current unit selected and the convoy
func swap_btn_current_unit_and_convoy():
	# Make sure the current unit selected is not empty
	if current_unit_selected == null:
		return
	
	# Do not allow if unit inventory is empty
	if current_unit_selected.UnitInventory.inventory.size() == 0:
		return
	
	# Check what state we are in right now
	match current_convoy_status:
		CONVOY_STATUS.SELECT_ITEM:
			# Activate Unit Inventory Display
			$"Unit Inventory Display".allow_input_last_pick()
			
			# Set text
			change_text("Select Item to Deposit")
			
			# Set new convoy status
			current_convoy_status = CONVOY_STATUS.DEPOSIT
			
			# Deactive current lists
			deactivate_list_no_hide(all_lists_array[current_list_selected_index], false)
			
		CONVOY_STATUS.DEPOSIT:
			# Deactivate Unit Inventory display
			$"Unit Inventory Display".disallow_input()

			change_text("Select Item to Withdraw")

			# Activate list again
			activate_list(all_lists_array[current_list_selected_index])
			all_lists_array[current_list_selected_index].item_list_node.select(0)

			# Set new status
			current_convoy_status = CONVOY_STATUS.SELECT_ITEM

			set_process_input(true)

func _on_Timer_timeout():
	# Increase the index
	if background_index + 1 > all_backgrounds.size() - 1:
		background_index = 0
	else:
		background_index += 1
	
	# Play fade out
	$AnimationPlayer.play("Fade")
	yield($AnimationPlayer,"animation_finished")
	
	# Set new background
	$Background.texture = all_backgrounds[background_index]
	
	# Fade backwards
	$AnimationPlayer.play_backwards("Fade")

func _on_Yes_No_Box_Generic_option_selected(yes_no_option):
	match current_convoy_status:
		CONVOY_STATUS.PASS_ITEM_TO_UNIT:
			if yes_no_option == true:
				# Check if the inventory of the unit is full
					if current_unit_selected.UnitInventory.inventory.size() == Unit_Inventory.MAX_INVENTORY:
						# Set text of convoy label
						change_text("This unit's inventory is full!")
						
						# Play can't sound
						$"All Lists/Axe/Hand Selector/Invalid".play(0)
						
						# Wait 1 second
						yield(get_tree().create_timer(1), "timeout")
						
						# Set text of convoy label
						change_text("Convoy")
						
						# Activate the last list
						activate_list(all_lists_array[current_list_selected_index])
						item_stats_label.show()
						set_process_input(true)
						
					else:
						# Send item to unit
						send_item_to_unit(current_unit_selected)
						
						# Refresh the Unit Inventory Display
						unit_inventory.populate_list_of_items(current_unit_selected)
						
						yield(get_tree().create_timer(1), "timeout")
						
						# Set status back
						current_convoy_status = CONVOY_STATUS.SELECT_ITEM
						
						# Allow Input again
						set_process_input(true)
						change_text("Convoy")
			else:
				# Activate list again
				activate_list(all_lists_array[current_list_selected_index])
			
				# Set new status
				current_convoy_status = CONVOY_STATUS.SELECT_ITEM
				
				# Activate item stats
				$"Item Stats".show()
				change_text("Convoy")
				
				# Activate Input again
				set_process_input(true)
		CONVOY_STATUS.CONFIRM_SELL:
			if yes_no_option == true:
				# Increase the money amount
				BattlefieldInfo.money += all_lists_array[current_list_selected_index].get_item_selected().get_selling_cost()
				
				# Delete the item
				all_lists_array[current_list_selected_index].delete_item()
				
				# Sleep 0.5 seconds
				yield(get_tree().create_timer(0.5), "timeout")
				
				# Back to the select item
				current_convoy_status = CONVOY_STATUS.SELL_ITEM
				change_text("Select Item to Sell")
				item_stats_label.show()
				activate_list(all_lists_array[current_list_selected_index])
				set_process_input(true)
				
			else:
				# Back to the select item
				current_convoy_status = CONVOY_STATUS.SELL_ITEM
				change_text("Select Item to Sell")
				item_stats_label.show()
				activate_list(all_lists_array[current_list_selected_index])
				set_process_input(true)
		CONVOY_STATUS.CONFIRM_DEPOSIT:
			if yes_no_option == true:
				# Get the item from the inventory of the unit
				var item_to_transfer = $"Unit Inventory Display".current_item_selected
				
				# Remove from the unit's inventory
				current_unit_selected.UnitInventory.remove_do_not_delete_item(item_to_transfer)
				
				# Add the item to the convoy
				add_item_to_convoy(item_to_transfer)
				
				# Refresh the inventory display
				unit_inventory.populate_list_of_items(current_unit_selected)
				
				# Wait 0.5 second
				yield(get_tree().create_timer(0.5), "timeout")
				
				# Check if the unit's inventory is empty
				if current_unit_selected.UnitInventory.inventory.size() == 0:
					# Disable the box and go straight back to the item selection
					$"Yes No Box Generic".exit()
					
					# Stop the item selection
					$"Unit Inventory Display".disallow_input()
					
					# Change text
					change_text("Select Item to withdraw")
					
					# Allow input
					activate_list(all_lists_array[current_list_selected_index])
					current_convoy_status = CONVOY_STATUS.SELECT_ITEM
					set_process_input(true)
					
				else:
					# Set text
					change_text("Select Item to Deposit")
					
					# Allow input on the unit inventory display
					$"Unit Inventory Display".allow_input()
					set_process_input(true)
					
					# Set back to deposit state
					current_convoy_status = CONVOY_STATUS.DEPOSIT
			else:
				# Set text
				change_text("Select Item to Deposit")
				
				# Hide and disable the yes no box
				$"Yes No Box Generic".go_back()
				
				# Start inventory again
				$"Unit Inventory Display".allow_input_last_pick()
				
				# Set state again
				current_convoy_status = CONVOY_STATUS.DEPOSIT

func _on_no_selected_from_generic():
	if current_convoy_status == CONVOY_STATUS.CONFIRM_DEPOSIT:
		# Set text
		change_text("Select Item to Deposit")
		
		# Hide and disable the yes no box
		$"Yes No Box Generic".exit()
		
		# Start inventory again
		$"Unit Inventory Display".allow_input_last_pick()
		
		# Set state again
		current_convoy_status = CONVOY_STATUS.DEPOSIT
		
		# Allow input again
		set_process_input(true)

# Save current status of the convoy
func save():
	var save_dict = {
		"Sword" : [],
		"Lance" : [],
		"Axe" : [], 
		"Bow" : [],
		"Tome" : [],
		"Heal" : [],
		"Consumable" : []
	}
	
	# Save each list with the items in them
	# Swords
	for sword in $"All Lists/Sword".item_tree_node.get_children():
		save_dict["Sword"].append(sword.save())
	
	# Lance
	for lance in $"All Lists/Lance".item_tree_node.get_children():
		save_dict["Lance"].append(lance.save())
	
	# Axe
	for axe in $"All Lists/Axe".item_tree_node.get_children():
		save_dict["Axe"].append(axe.save())
	
	# Bow
	for bow in $"All Lists/Bow".item_tree_node.get_children():
		save_dict["Bow"].append(bow.save())
	
	# Tome
	for tome in $"All Lists/Tome".item_tree_node.get_children():
		save_dict["Tome"].append(tome.save())
	
	# Heal
	for heal in $"All Lists/Heal".item_tree_node.get_children():
		save_dict["Heal"].append(heal.save())
	
	# Consumable
	for consumable in $"All Lists/Consumable".item_tree_node.get_children():
		save_dict["Consumable"].append(consumable.save())
	
	return save_dict

# Load the convoy
func load_convoy(json_convoy_data):
	var all_items_name = ["Sword", "Lance", "Axe", "Bow", "Tome", "Heal", "Consumable"]
	
	for item_name in all_items_name:
		for json_item_name in json_convoy_data[item_name]:
			var item_object = load(json_item_name["filename"]).instance()
			add_item_to_convoy(item_object)
			item_object.load_item(json_item_name["item_stats"])
