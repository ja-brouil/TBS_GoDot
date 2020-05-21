extends Control

# Node access
onready var inventory_list = $"Background Color/Inventory List"
onready var unit_name = $"Background Color/Unit Name"

# Array that holds all the items from said unit
var unit_inventory = []

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
	
	# Test unit
#	var seth_path = load("res://Scenes/Units/Player_Units/AllyUnits/Seth/Seth.tscn")
#	var seth_t = seth_path.instance()
#	$"TEST NODE".add_child(seth_t)
#	seth_t.UnitStats.identifier = "Seth"
#	seth_t.UnitStats.name = "Seth"

	# Start TEST
	#start(seth_t)

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		process_accept()

func process_accept():
	print("The Selected item is ")

func start(unit):
	# Show the UI
	visible = true
	
	# Populate the list
	populate_list_of_items(unit)
	
	# Set the name of inventory box
	unit_name.text = str(unit.UnitStats.name, "'s Inventory")

func allow_input():
	# Allow input
	set_process_input(true)
	inventory_list.focus_mode = Control.FOCUS_ALL
	inventory_list.grab_focus()
	inventory_list.select(0)

# Get the name of each item, the icon and create a line item with them
func populate_list_of_items(unit):
	# Clear the unit array
	unit_inventory.clear()
	
	# Clear inventiory list
	inventory_list.clear()
	
	for item in unit.UnitInventory.inventory:
		inventory_list.add_item(item.item_name, item.icon, true)
		unit_inventory.append(item)

func exit():
	# Hide the UI
	visible = true
	
	# Disallow input
	set_process_input(false)
	inventory_list.focus_mode = Control.FOCUS_NONE
	inventory_list.release_focus()
	inventory_list.unselect_all()
	
	# Clear unit array
	unit_inventory.clear()


func _on_Inventory_List_item_selected(index):
	print(inventory_list.get_item_text(index), " ", index)
