extends Control

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
enum CONVOY_STATUS {SELECT_UNIT, SELECT_ITEM, OFF}
var current_convoy_status

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
	
	start()

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		pass
	elif Input.is_action_just_pressed("ui_down"):
		pass
	elif Input.is_action_just_pressed("ui_left"):
		# Do not process if not in item select mode
		if current_convoy_status == CONVOY_STATUS.SELECT_UNIT:
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
		if current_convoy_status == CONVOY_STATUS.SELECT_UNIT:
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
	
	if Input.is_action_just_pressed("debug"):
		# Add new tome
		add_item_to_convoy(load(ALL_ITEMS_REF.all_items["Silver Lance"]).instance())
#		if all_lists_array[current_list_selected_index].item_list.size() == 0:
#			item_text_reset()
#			return
#		print(all_lists_array[current_list_selected_index].get_item_selected())
#		all_lists_array[current_list_selected_index].delete_item()

# Start the convoy
func start():
	# TEST LOAD ITEMS
	test()
	
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
	
	# Set to select item
	current_convoy_status = CONVOY_STATUS.SELECT_ITEM

func start_with_unit_selected(unit):
	current_unit_selected = unit
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

func deactivate_list(list, var reset_index = true):
	# Stop process
	list.exit()
	
	# Set new index
	if (reset_index):
		current_item_selected_index = 0

func deactivate_all_lists():
	for list in all_lists_array:
		deactivate_list(list)

func exit():
	# Remove the unit
	current_unit_selected = null

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
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	
	$"Convoy Music".play(0)

func item_text_reset():
	item_stats_label.text = "Item Stats"

func process_accept():
	match current_convoy_status:
		CONVOY_STATUS.SELECT_ITEM:
			# Is the current list empty
			if all_lists_array[current_list_selected_index].item_list.size() == 0:
				return
			
			# Set new state
			current_convoy_status = CONVOY_STATUS.SELECT_UNIT
			
			# Play hand sound
			$"Hand Selector/Accept".play(0)
			
			# Hide item stats
			item_stats_label.hide()
			
			# Start unit picker
			unit_picker.start()
			print(all_lists_array[current_list_selected_index].get_item_selected().name)
			
			# Stop input on the main input
			deactivate_list(all_lists_array[current_list_selected_index], false)
			# set_process_input(false)
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
				
				# We have space in the inventory so send this item to the player
				# Get the item to transfer
				var item_to_transfer = all_lists_array[current_list_selected_index].transfer_item()
				
				# Move the item to the unit's inventory
				unit_picker.unit_selected.UnitInventory.add_item(item_to_transfer)
				
				# Back to convoy
				current_convoy_status = CONVOY_STATUS.SELECT_ITEM
				
				# Show Item stats
				item_stats_label.show()
				
				# Hide unit picker
				unit_picker.exit()
				
				# Activate the current list
				activate_list(all_lists_array[current_list_selected_index])

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
