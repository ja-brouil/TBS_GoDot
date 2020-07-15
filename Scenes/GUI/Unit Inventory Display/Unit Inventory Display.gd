extends Control

# Node access
onready var inventory_list = $"Background Color/Inventory List"
onready var unit_name = $"Background Color/Unit Name"

# Array that holds all the items from said unit
var unit_inventory = []
var current_item_selected

# Signal to know when something is picked
signal item_selected

# Keep track of last index
var last_index = 0

# UI State
enum Unit_Inventory_Status {SELECT_ITEM, CONFIRM_ITEM}

# Called when the node enters the scene tree for the first time.
func _ready():
	# Disable input at the start
	set_process_input(false)
	inventory_list.focus_mode = Control.FOCUS_NONE
	inventory_list.unselect_all()
	inventory_list.release_focus()
	
	# Hide Scroll bar
	inventory_list.get_v_scroll().mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_list.get_v_scroll().modulate = Color(1,1,1,0)


func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		process_accept()

func process_accept():
	# Add null crash prevent here because if you spam the accept button too fast it will crash
	if current_item_selected != null:
		emit_signal("item_selected")

func start(unit):
	set_process_input(false)
	# Populate the list
	populate_list_of_items(unit)
	
	# Show the UI
	visible = true
	
	$Anim.play("Fade")
	yield($Anim,"animation_finished")
	
	# Set the name of inventory box
	unit_name.text = str(unit.UnitStats.name, "'s Inventory")
	
	# Set to first item | Do not select if the inventory is empty
	if unit.UnitInventory.inventory.size() > 0:
		current_item_selected = unit_inventory[0]
	

func start_with_input(unit):
	start(unit)
	allow_input()

func allow_input():
	# Allow input
	inventory_list.focus_mode = Control.FOCUS_ALL
	inventory_list.grab_focus()
	if inventory_list.items.size() != 0:
		inventory_list.select(0)
		_on_Inventory_List_item_selected(0)
	set_process_input(true)

func allow_input_last_pick():
	# Allow input
	inventory_list.focus_mode = Control.FOCUS_ALL
	inventory_list.grab_focus()
	if inventory_list.items.size() != 0:
		inventory_list.select(last_index)
		_on_Inventory_List_item_selected(last_index)
	set_process_input(true)

# Get the name of each item, the icon and create a line item with them
func populate_list_of_items(unit):
	# Clear the unit array
	unit_inventory.clear()
	
	# Clear inventiory list
	inventory_list.clear()
	
	for item in unit.UnitInventory.inventory:
		inventory_list.add_item(item.item_name, item.icon, true)
		unit_inventory.append(item)

# Disallow input
func disallow_input():
	# Disallow input
	set_process_input(false)
	inventory_list.focus_mode = Control.FOCUS_NONE
	inventory_list.release_focus()
	inventory_list.unselect_all()
	

func exit():
	# Fade
	$Anim.play_backwards("Fade")
	yield($Anim,"animation_finished")
	
	# Hide the UI
	visible = false
	
	# Disallow input
	disallow_input()
	
	# Clear unit a
	reset()

func reset():
	unit_inventory.clear()
	last_index = 0
	current_item_selected = null

func _on_Inventory_List_item_selected(index):
	current_item_selected = unit_inventory[index]
	last_index = index
