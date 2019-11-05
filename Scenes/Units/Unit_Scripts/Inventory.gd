extends Node2D

# Unit's inventory
var inventory = []
const MAX_INVENTORY = 6

# Attack range based on weapon
var MAX_ATTACK_RANGE = 1

# Heal Range
var MAX_HEAL_RANGE = 2

# Current item equipped
var current_item_equipped

# Called when the node enters the scene tree for the first time.
func _ready():
	# Placeholder sword
	var iron_sword = load("res://Scenes/Items/Item.tscn").instance()
	add_child(iron_sword)
	add_item(iron_sword)
	current_item_equipped = inventory[0]

# Add item to the inventory
func add_item(item):
	if inventory.size() == MAX_INVENTORY:
		print("Can't add item placeholder! Send to convoy!")
	else:
		inventory.append(item)