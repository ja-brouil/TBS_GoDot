extends Control

# Array that holds all the units
var all_units_available = {}

# Unit Selected
var unit_selected = null

# Unit selected signal
signal unit_picked

# Node access
onready var unit_list = $"Unit List"
onready var anim = $"Anim"

func _ready():
	set_process_input(false)
	unit_list.unselect_all()
	unit_list.release_focus()
	
	# Hide Scroll bar
	unit_list.get_v_scroll().mouse_filter = Control.MOUSE_FILTER_IGNORE
	unit_list.get_v_scroll().modulate = Color(1,1,1,0)
	
	
	# Test adding units
	# Eirika Test
	var eririka_path = load("res://Scenes/Units/Player_Units/AllyUnits/Eirika/Eirika.tscn")
	var eirika_t = eririka_path.instance()
	$"TEST NODE".add_child(eirika_t)
	eirika_t.UnitStats.identifier = "Eirika"
	
	# Seth test
	var seth_path = load("res://Scenes/Units/Player_Units/AllyUnits/Seth/Seth.tscn")
	var seth_t = seth_path.instance()
	$"TEST NODE".add_child(seth_t)
	seth_t.UnitStats.identifier = "Seth"
	seth_t.UnitStats.name = "Seth"
	
	BattlefieldInfo.ally_units["Eirika"] = eirika_t
	BattlefieldInfo.ally_units["Seth"] = seth_t
	
	for child in $"TEST NODE".get_children():
		child.position = Vector2(-100, -100)

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("unit_picked", unit_selected)

func start():
	# Populate the list
	populate_array_with_units()
	
	# Play the animation
	visible = true
	anim.play("Fade")
	yield(anim,"animation_finished")
	
	# Allow input
	unit_list.focus_mode = Control.FOCUS_ALL
	unit_list.grab_focus()
	unit_list.select(0)
	set_process_input(true)

func exit():
	# Stop input
	set_process_input(false)
	unit_list.focus_mode = Control.FOCUS_NONE
	unit_list.release_focus()
	unit_list.unselect_all()
	
	# Go away
	anim.play_backwards("Fade")
	yield(anim,"animation_finished")
	visible = false

func stop_input():
	set_process_input(false)
	unit_list.focus_mode = Control.FOCUS_NONE
	unit_list.release_focus()
	unit_list.unselect_all()

func allow_input():
	# Allow input
	unit_list.focus_mode = Control.FOCUS_ALL
	unit_list.grab_focus()
	unit_list.select(0)
	set_process_input(true)

# Merge the arrays together
func populate_array_with_units():
	# Clear
	all_units_available.clear()
	
	# Get all units in the Battlefield info Ally Units
	for ally_unit in BattlefieldInfo.ally_units.values():
		all_units_available[ally_unit.UnitStats.identifier] = ally_unit
	
	# Get all units not in the battle
	for ally_unit in BattlefieldInfo.ally_units_not_in_battle.values():
		if !all_units_available.has(ally_unit):
			all_units_available[ally_unit.UnitStats.identifier] = ally_unit
	
	# Clear the current list
	unit_list.clear()
	for ally_unit in all_units_available.values():
		unit_list.add_item(ally_unit.UnitStats.name, ally_unit.unit_portrait_path, true)
		
	# Remove unit selected
	unit_selected = get_unit(0)

# Get the unit wanted
func get_unit(index):
	return all_units_available[unit_list.get_item_text(index)]

func set_new_text_instructions(instructions):
	$Instructions.text = instructions

func _on_Unit_List_item_selected(index):
	unit_selected = get_unit(index)
