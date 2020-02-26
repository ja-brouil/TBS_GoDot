extends Control

# Convoy is the inventory system for storing extra items
# Item selected
var current_item_selected_index = 0

# Current list selected
var previous_list_selected_index = 0
var current_list_selected_index = 0

# Positioning
const LIST_POSITION = Vector2(128, 6)

# Node access
onready var sword_list = $Sword
onready var lance_list = $Lance
onready var axe_list = $"Axe"

# Store all the nodes into this array for controlled access
var all_lists_array = []

func _ready():
	# Set appropriate strings
	sword_list.label_text = "Sword"
	lance_list.label_text = "Lance"
	axe_list.label_text = "Axe"
	
	start()

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		pass
	elif Input.is_action_just_pressed("ui_down"):
		pass
	elif Input.is_action_just_pressed("ui_left"):
		# Move one screen to the left
		previous_list_selected_index = current_list_selected_index
		current_list_selected_index -= 1
		
		# Do nothing if goes underneath 0
		if current_list_selected_index < 0:
			current_list_selected_index = 0
			return
		
		# Set the next list
		next_list(all_lists_array[previous_list_selected_index],all_lists_array[current_list_selected_index])
	elif Input.is_action_just_pressed("ui_right"):
		# Move one screen to the left
		previous_list_selected_index = current_list_selected_index
		current_list_selected_index += 1
		
		# Do nothing if goes underneath 0
		if current_list_selected_index > all_lists_array.size() - 1:
			current_list_selected_index = all_lists_array.size()
			return
		
		# Set the next list
		next_list(all_lists_array[previous_list_selected_index],all_lists_array[current_list_selected_index])

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

func add_item_to_convoy(item):
	pass

func next_list(next_list, previous_list):
	deactivate_list(previous_list)
	activate_list(next_list)

func activate_list(list):
	# Start process
	list.visible = true
	
	# Is the list empty?
	
	if list.item_list_node:
		pass
	list.set_process_input(true)
	list.item_list_node.select(0)
	list.item_list_node.grab_focus()

func deactivate_list(list):
	# Stop process
	list.visible = false
	list.set_process_input(false)
	list.item_list_node.unselect_all()
	list.item_list_node.release_focus()
	
	# Set new index
	current_item_selected_index = 0

func deactivate_all_lists():
	pass

func exit():
	pass

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
	
	# Lance
	# Nothing, as a test
	
