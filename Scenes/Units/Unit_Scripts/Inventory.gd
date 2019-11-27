extends Node2D

# Unit's inventory
var inventory = []
const MAX_INVENTORY = 6

# Attack range based on weapon
var MAX_ATTACK_RANGE = 0

# Heal Range
var MAX_HEAL_RANGE = 0

# Current item equipped
var current_item_equipped

# Add item to the inventory
func add_item(item):
	if inventory.size() == MAX_INVENTORY:
		print("Can't add item placeholder! Send to convoy!")
	else:
		add_child(item)
		inventory.append(item)
		
		# Check what kind of item this is
		# Process healing item
		if item.item_class == Item.ITEM_CLASS.MAGIC && item.weapon_type == Item.WEAPON_TYPE.HEALING:
			if item.max_range > MAX_HEAL_RANGE:
				MAX_HEAL_RANGE = item.max_range
		# Anyone else that isn't consumable and a healing item
		elif item.item_class != Item.ITEM_CLASS.CONSUMABLE && item.weapon_type != Item.WEAPON_TYPE.HEALING:
			if item.max_range > MAX_ATTACK_RANGE:
				MAX_ATTACK_RANGE = item.max_range
	
	if current_item_equipped == null:
		current_item_equipped = item