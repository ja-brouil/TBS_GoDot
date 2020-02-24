extends Control

# Convoy is the inventory system for storing extra items

# Item selected
var current_item_selected

# Current list selected
var current_list_selected

# Positioning
const LIST_POSITION = Vector2(128, 6)

# Node access
onready var sword_list = $Sword
onready var lance_list = $Lance
onready var axe_list = $"Axe"

func _ready():
	# Set appropriate strings
	sword_list.label_text = "Sword"
	lance_list.label_text = "Lance"
	axe_list.label_text = "Axe"
	
	test()

func start():
	pass

func add_item_to_convoy(item):
	pass

func activate_list(list):
	pass

func deactivate_list(list):
	pass

func deactivate_all_lists():
	pass

func exit():
	pass

func test():
	var a = BattlefieldInfo.item_database.create_item(ALL_ITEMS_REF.all_items["Iron Sword"])
	
	yield(get_tree().create_timer(3), "timeout")
	
	$Sword.add_item(a)
	$Sword.add_item(a)
