extends Control

# Convoy is the inventory system for storing extra items
# Item selected
var current_item_selected_index = 0

# Unit selected
var current_unit_selected = null

# Current list selected
var previous_list_selected_index = 0
var current_list_selected_index = 0

# Positioning
const LIST_POSITION = Vector2(128, 6)

# Node access
onready var sword_list = $Sword
onready var lance_list = $Lance
onready var axe_list = $"Axe"
onready var bow_list = $Bow
onready var tome_list = $Tome
onready var heal_list = $Heal
onready var consumable_list = $Consumable
onready var item_stats_label = $"Item Stats"

# Store all the nodes into this array for controlled access
var all_lists_array = []

# Background list
var background_index = 0
var all_backgrounds = [
	preload("res://assets/backgrounds/FE BG 1.png"),
	preload("res://assets/backgrounds/FE BG 2.jpg"),
	preload("res://assets/backgrounds/FE BG 3.jpg"),
	preload("res://assets/backgrounds/FE BG 4.jpg"),
	preload("res://assets/backgrounds/FE BG 5.jpg")
]

func _ready():
	# Set appropriate strings
	sword_list.set_text("Swords")
	lance_list.set_text("Lances")
	axe_list.set_text("Axes")
	bow_list.set_text("Bow")
	tome_list.set_text("Tomes")
	heal_list.set_text("Healing Staves")
	consumable_list.set_text("Consumables")
	
	start()

func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		pass
	elif Input.is_action_just_pressed("ui_down"):
		pass
	elif Input.is_action_just_pressed("ui_left"):
		
		# Do nothing if goes underneath 0
		if current_list_selected_index - 1 < 0:
			return
		
		# Set new numbers
		previous_list_selected_index = current_list_selected_index
		current_list_selected_index -= 1
		
		# Set the next list
		next_list(all_lists_array[previous_list_selected_index],all_lists_array[current_list_selected_index])
		
		# Play Sound
		$"Hand Selector/Move2".play(0)
		
	elif Input.is_action_just_pressed("ui_right"):
		
		# Do nothing if goes above the size of the array
		if current_list_selected_index + 1 > all_lists_array.size() - 1:
			return
		
		# Set new numbers
		previous_list_selected_index = current_list_selected_index
		current_list_selected_index += 1
		
		# Set the next list
		next_list(all_lists_array[previous_list_selected_index], all_lists_array[current_list_selected_index])
		
		# Play Sound
		$"Hand Selector/Move2".play(0)
		
	elif Input.is_action_just_pressed("ui_accept"):
		pass
	elif Input.is_action_just_pressed("ui_cancel"):
		pass
	
	if Input.is_action_just_pressed("debug"):
		# Add new tome
		add_item_to_convoy(load(ALL_ITEMS_REF.all_items["Silver Lance"]).instance())
#		if all_lists_array[current_list_selected_index].item_list.size() == 0:
#			item_text_reset()
#			return
#		print(all_lists_array[current_list_selected_index].get_item_selected())
#		all_lists_array[current_list_selected_index].delete_item()

func start():
	# TEST LOAD ITEMS
	test()
	
	# Set to swords
	current_list_selected_index = 0
	
	# Reset tracking variables
	current_item_selected_index = 0
	
	# Set all lists into the array
	all_lists_array.append(sword_list)
	all_lists_array.append(lance_list)
	all_lists_array.append(axe_list)
	all_lists_array.append(bow_list)
	all_lists_array.append(tome_list)
	all_lists_array.append(heal_list)
	all_lists_array.append(consumable_list)
	
	# Start first list
	deactivate_all_lists()
	activate_list(all_lists_array[current_list_selected_index])


func start_with_unit_selected(unit):
	current_unit_selected = unit
	start()

# Add an item to the convoy
func add_item_to_convoy(item):
	item._ready()
	# If the item is a consumable, put it in the consumable list
	if item.item_class == Item.ITEM_CLASS.CONSUMABLE:
		consumable_list.add_item(item)
	else:
		# Place weapon in correct location
		match item.weapon_type:
			Item.WEAPON_TYPE.SWORD:
				sword_list.add_item(item)
			Item.WEAPON_TYPE.AXE:
				axe_list.add_item(item)
			Item.WEAPON_TYPE.LANCE:
				lance_list.add_item(item)
			Item.WEAPON_TYPE.BOW:
				bow_list.add_item(item)
			Item.WEAPON_TYPE.LIGHT, Item.WEAPON_TYPE.DARK, Item.WEAPON_TYPE.ELEMENTAL:
				tome_list.add_item(item)
			Item.WEAPON_TYPE.HEALING:
				heal_list.add_item(item)

func next_list(previous_list, next_list):
	deactivate_list(previous_list)
	activate_list(next_list)

func activate_list(list):
	list.start()

func deactivate_list(list):
	# Stop process
	list.exit()
	
	# Set new index
	current_item_selected_index = 0

func deactivate_all_lists():
	for list in all_lists_array:
		deactivate_list(list)

func exit():
	# Remove the unit
	current_unit_selected = null

func test():
	# Swords
	sword_list.add_item(load(ALL_ITEMS_REF.all_items["Iron Sword"]).instance())
	sword_list.add_item(load(ALL_ITEMS_REF.all_items["Iron Sword"]).instance())
	sword_list.add_item(load(ALL_ITEMS_REF.all_items["Killing Edge"]).instance())
	
	# Axe
	axe_list.add_item(load(ALL_ITEMS_REF.all_items["Iron Axe"]).instance())
	axe_list.add_item(load(ALL_ITEMS_REF.all_items["Iron Axe"]).instance())
	axe_list.add_item(load(ALL_ITEMS_REF.all_items["Iron Axe"]).instance())
	axe_list.add_item(load(ALL_ITEMS_REF.all_items["Iron Axe"]).instance())
	
	# Modify the axes a little bit
	axe_list.item_list[1].uses = 5
	axe_list.item_list[1].crit = 15
	axe_list.item_list[2].uses = 32
	axe_list.item_list[3].max_range = 4
	
	# Lance
	# Nothing, as a test
	
	# No Heal but put tomes
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Flux Tome"]).instance())
	tome_list.add_item(load(ALL_ITEMS_REF.all_items["Fire Tome"]).instance())
	
	$"Convoy Music".play(0)

func item_text_reset():
	item_stats_label.text = "Item Stats"

func _on_Timer_timeout():
	# Increase the index
	if background_index + 1 > all_backgrounds.size() - 1:
		background_index = 0
	else:
		background_index += 1
	
	# Play fade out
	$AnimationPlayer.play("Fade")
	yield($AnimationPlayer,"animation_finished")
	
	# Set new background
	$Background.texture = all_backgrounds[background_index]
	
	# Fade backwards
	$AnimationPlayer.play_backwards("Fade")
