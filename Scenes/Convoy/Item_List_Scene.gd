extends ColorRect

# List to hold the items
var item_list = []

# Item Selected
var item_selected = null

# Node access
onready var label = $"Item Label"
onready var item_list_node = $"Item List" 
onready var item_tree_node = $"Item Tree"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Disable the Item List Stuff
	item_list_node.get_v_scroll().mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_list_node.get_v_scroll().modulate = Color(1,1,1,0)
	
	# Disable input
	disable_input()

func start():
	visible = true
	allow_input()
	
	# Set text for the new item
	if item_list.size() != 0:
		item_selected = item_list[0]
		get_parent().item_stats_label.text = str("Item Stats\n", item_selected.get_stats_stringify())
	else:
		get_parent().item_text_reset()

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

func remove_item(index):
	# Remove from the array
	var item_to_return = item_list[index]
	item_tree_node.remove_child(item_to_return)
	item_list.remove(index)
	
	# Remove from the item list
	item_list_node.remove_item(index)
	
	# Return the item
	return item_to_return

func allow_input():
	item_list_node.grab_focus()
	item_list_node.set_process_input(true)
	if item_list.size() != 0:
		item_list_node.select(0)

func disable_input():
	item_list_node.set_process_input(false)
	item_list_node.unselect_all()
	item_list_node.release_focus()
	

func _on_Item_List_item_selected(index):
	$"Hand Selector/Move".play(0)
	item_selected = item_list[index]
	
	# Set parent label
	get_parent().item_stats_label.text = str("Item Stats\n", item_selected.get_stats_stringify())
