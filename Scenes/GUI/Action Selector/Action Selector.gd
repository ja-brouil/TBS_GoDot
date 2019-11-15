extends Node2D

# Constants
const MARGIN_LEFT_OF_TOP = 18
const ACTION_SIZE_Y = 10

# Preload all the menu items
var attack = preload("res://Scenes/GUI/Action Selector/Actions/Attack.tscn").instance()
var item = preload("res://Scenes/GUI/Action Selector/Actions/Item.tscn").instance()
var trade = preload("res://Scenes/GUI/Action Selector/Actions/Trade.tscn").instance()
var wait = preload("res://Scenes/GUI/Action Selector/Actions/Wait.tscn").instance()
var node_array = {"attack": attack, "item": item, "trade": trade, "wait": wait}

# Keep track of all the actions that we have currently
var current_actions = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		var test_menu = ["attack", "wait", "item"]
		build_menu(test_menu)
	
	if Input.is_action_just_pressed("ui_cancel"):
		var test_menu = ["attack", "wait", "trade", "item"]
		build_menu(test_menu)

# Build the menu based on how many options there are
func build_menu(menu_items):
	# Remove old items
	for action_item in node_array.values():
		if self.has_node(action_item):
			remove_child(action_item)
	
	# Sort the array alphabetically
	menu_items.sort()
	
#	Get each item and build the menu
	var last_item = $"Action Menu/Top"
	for menu_item in menu_items:
		node_array[menu_item].position.x = MARGIN_LEFT_OF_TOP
		node_array[menu_item].position.y = last_item.position.y + ACTION_SIZE_Y - 1
		add_child(menu_item)
		last_item = node_array[menu_item]

	# Move bottom
	$"Action Menu/Bottom".position.y = last_item.position.y + ACTION_SIZE_Y
