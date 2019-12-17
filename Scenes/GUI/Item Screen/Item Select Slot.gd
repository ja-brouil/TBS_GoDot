extends Node2D

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
	$"Background/Icon".visible = true
	
	# Check if this is equipped
	if BattlefieldInfo.current_Unit_Selected.UnitInventory.current_item_equipped == item:
		$Background/anim.play("equipped")
	else:
		$Background/anim.stop(true)
		$"Background/Weapon Name".set("custom_colors/font_color", Color(1.0, 1.0, 1.0))

# Turn this into an empty slot
func empty_slot():
	$"Background/Weapon Name".text = ""
	
	$"Background/Uses".text = ""
	
	$"Background/Icon".visible = false