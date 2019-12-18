extends Node2D

var current_item

# Start the node with the data needed
func start(item):
	# Uses
	$"Background/Uses".text = str(item.uses)
	
	# Weapon name
	$"Background/Weapon Name".text = item.item_name
	
	# Icon
	$"Background/Icon".texture = item.icon
	$"Background/Icon".visible = true
	
	set_green_equipped(item)
	current_item = item

# Turn this into an empty slot
func empty_slot():
	$"Background/Weapon Name".text = ""
	
	$"Background/Uses".text = ""
	
	$"Background/Icon".visible = false

# Set Green for equipped
func set_green_equipped(item):
	if BattlefieldInfo.current_Unit_Selected.UnitInventory.current_item_equipped == item:
		$Background/anim.play("equipped")
	else:
		$Background/anim.stop(true)
		$"Background/Weapon Name".set("custom_colors/font_color", Color(1.0, 1.0, 1.0))