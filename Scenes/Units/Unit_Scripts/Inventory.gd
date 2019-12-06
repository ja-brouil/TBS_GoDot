extends Node2D

# Unit's inventory
var inventory = []
const MAX_INVENTORY = 6

# Attack range based on weapon
var MAX_ATTACK_RANGE = 0
var MIN_ATTACK_RANGE = 999

# Heal Range
var MAX_HEAL_RANGE = 0
var MIN_HEAL_RANGE = 999

# Current item equipped
var current_item_equipped

# Add item to the inventory
func add_item(item):
	if inventory.size() == MAX_INVENTORY:
		print("FROM: INVENTORY: Can't add item placeholder! Send to convoy!")
		item.queue_free()
	else:
		add_child(item)
		inventory.append(item)
		
		# Check what kind of item this is
		# Process healing item
		if item.item_class == Item.ITEM_CLASS.MAGIC && item.weapon_type == Item.WEAPON_TYPE.HEALING:
			if item.max_range > MAX_HEAL_RANGE:
				MAX_HEAL_RANGE = item.max_range
			if item.min_range < MIN_HEAL_RANGE:
				MIN_HEAL_RANGE = item.min_range
			# Set to equipped item
			if current_item_equipped == null:
				current_item_equipped = item
		# Anyone else that isn't consumable and a healing item
		elif item.item_class != Item.ITEM_CLASS.CONSUMABLE && item.weapon_type != Item.WEAPON_TYPE.HEALING:
			if item.max_range > MAX_ATTACK_RANGE:
				MAX_ATTACK_RANGE = item.max_range
			if item.min_range < MIN_ATTACK_RANGE:
				MIN_ATTACK_RANGE = item.min_range
			if current_item_equipped == null:
				current_item_equipped = item

# Remove an item from the unit's inventory
func remove_item(item):
	# Remove the item from the inventory and remove object from the system
	inventory.erase(item)
	item.queue_free()
	
	MAX_ATTACK_RANGE = 0
	MAX_HEAL_RANGE = 0
	
	# Get new max ranges
	for inv_item in inventory:
		if inv_item.item_class == Item.ITEM_CLASS.MAGIC && inv_item.weapon_type == Item.WEAPON_TYPE.HEALING:
			if inv_item.max_range > MAX_HEAL_RANGE:
				MAX_HEAL_RANGE = inv_item.max_range
			if item.min_range < MIN_HEAL_RANGE:
				MIN_HEAL_RANGE = item.min_range
		# Anyone else that isn't consumable and a healing item
		elif inv_item.item_class != Item.ITEM_CLASS.CONSUMABLE && inv_item.weapon_type != Item.WEAPON_TYPE.HEALING:
			if inv_item.max_range > MAX_ATTACK_RANGE:
				MAX_ATTACK_RANGE = inv_item.max_range
			if item.min_range < MIN_ATTACK_RANGE:
				MIN_ATTACK_RANGE = item.min_range
	
	# Equip next weapon
	for inv_item in inventory:
		# Grab next item | attack first then healing if we have nothing
		if inv_item.item_class != Item.ITEM_CLASS.CONSUMABLE && inv_item.weapon_type != Item.WEAPON_TYPE.HEALING && current_item_equipped != null:
			current_item_equipped = inv_item
		elif inv_item.item_class == Item.ITEM_CLASS.MAGIC && inv_item.weapon_type == Item.WEAPON_TYPE.HEALING && current_item_equipped != null:
			current_item_equipped = inv_item
		
		# Set to unarmed if we STILL have nothing
		if current_item_equipped == null:
			current_item_equipped = $Unarmed

func set_unarmed():
	current_item_equipped = $Unarmed