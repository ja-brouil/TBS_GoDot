extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Start the node with the data needed
func start(item):
	# Uses
	$"Background/Uses".text = str(item.uses)
	
	# Weapon name
	$"Background/Weapon Name".text = item.item_name
	
	# Icon
	$"Background/Icon".texture = item.icon
	
	# Add to group
	add_to_group(GroupNames.ITEM_SLOT_GROUP_NAME)