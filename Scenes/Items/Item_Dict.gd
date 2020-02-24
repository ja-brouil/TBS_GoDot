extends Reference

class_name ALL_ITEMS_REF

# Dictionary container all the items with their position
# Default items
const all_items = {
	"Iron Sword" : "res://Scenes/Items/Swords/Iron Sword.tscn",
	"Iron Bow" : "res://Scenes/Items/Bows/Iron Bow.tscn",
	"Iron Axe" : "res://Scenes/Items/Axes/Iron Axe.tscn",
	"Silver Lance": "res://Scenes/Items/Lance/Silver Lance.tscn",
	"Iron Lance": "res://Scenes/Items/Lance/Iron Lance.tscn",
	"Fire Tome" : "res://Scenes/Items/Tomes/Fire.tscn",
	"Heal Staff" : "res://Scenes/Items/Staves/Heal.tscn",
	"Killing Edge" : "res://Scenes/Items/Swords/Killing Edge.tscn"
}

# Add item
func add_item(item_id, item):
	# Do not allow duplicates
	if !all_items.has(item_id):
		all_items[item_id] = item
	else:
		print("Error Item Ref: Item already exists.")

# Remove item
func remove_item(item_id):
	if all_items.has(item_id):
		all_items.erase(item_id)
	else:
		print("Error Item Ref: No such item exists.")

# Get item
func get_item(item_id):
	if all_items.has(item_id):
		return all_items[item_id]
	else:
		print("Error Item Ref: No such item exists.")

# Create an item
func create_item(item_id):
	var item = load(item_id)
	var new_item = item.instance()
	
	return new_item
