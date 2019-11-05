extends Node2D

# Unit's inventory
var Inventory = []
const MAX_INVENTORY = 6

# Attack range based on weapon
var MAX_ATTACK_RANGE = 1

# Heal Range
var MAX_HEAL_RANGE = 2

# Current item equipped
var current_item_equipped

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.