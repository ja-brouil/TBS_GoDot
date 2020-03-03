extends ColorRect

# List to hold the items
var item_list = []

# Item Selected
var item_selected = null
var item_index = 0

# Node access
onready var label = $"Item Label"
onready var item_list_node = $"Item List" 
onready var item_tree_node = $"Item Tree"

# Convoy access
var convoy

# Called when the node enters the scene tree for the first time.
func _ready():
	# Disable the Item List Stuff
	item_list_node.get_v_scroll().mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_list_node.get_v_scroll().modulate = Color(1,1,1,0)
	
	# Disable input
	disable_input()

func start(convoy):
	self.convoy = convoy
	visible = true
	allow_input()
	
	# Set text for the new item
	if item_list.size() != 0:
		item_index = 0
		item_selected = item_list[item_index]
		convoy.item_stats_label.text = str("Item Stats\n", item_selected.get_stats_stringify())
	else:
		convoy.item_text_reset()

func exit():
	visible = false
	disable_input()

func add_item(item):
	# Attach to tree
	item_tree_node.add_child(item)
	
	# Add to the array
	item_list.append(item)
	
	# Grab the name of the item and icon and add it as an item
	item_list_node.add_item(item.item_name, item.icon)

func set_text(text):
	label.text = text

func get_item_selected():
	return item_list[item_index]

func transfer_item():
	# Get the item from the array
	var item_to_delete = item_list[item_index]
	
	# Remove it from the array
	item_list.erase(item_to_delete)
	
	# Remove it from the list node
	item_list_node.remove_item(item_index)
	
	# Remove child
	item_tree_node.remove_child(item_to_delete)
	
	# Array is not empty, set new index
	if item_index > item_list.size() - 1:
		_on_Item_List_item_selected(item_list.size() - 1)
		allow_input()
	else:
		_on_Item_List_item_selected(item_index)
		allow_input()
		
	# Return the item
	return item_to_delete

func delete_item():
	# Get the item from the array
	var item_to_delete = item_list[item_index]
	
	# Delete the item from the array
	item_list.erase(item_to_delete)
	
	# Remove the item from the List Node
	item_list_node.remove_item(item_index)
	
	# Is the array now empty?
	if item_list.size() == 0:
		disable_input()
		return
	
	# Array is not empty, set new index
	if item_index > item_list.size() - 1:
		_on_Item_List_item_selected(item_list.size() - 1)
		allow_input()
	else:
		_on_Item_List_item_selected(item_index)
		allow_input()


func allow_input():
	item_list_node.focus_mode = Control.FOCUS_ALL
	item_list_node.grab_focus()
	item_list_node.set_process_input(true)
	if item_list.size() != 0:
		item_list_node.select(item_index)

func disable_input():
	item_list_node.set_process_input(false)
	item_list_node.unselect_all()
	item_list_node.release_focus()
	

func _on_Item_List_item_selected(index):
	if index < 0:
		return
	$"Hand Selector/Move".play(0)
	item_index = index
	item_selected = item_list[index]
	
	# Set parent label
	convoy.item_stats_label.text = str("Item Stats\n", item_selected.get_stats_stringify())
