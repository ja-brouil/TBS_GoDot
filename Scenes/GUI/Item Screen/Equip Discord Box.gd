extends Control

export var is_active = false

const ACTION_SIZE_Y = 19

var item_selected
var current_options = ["Equip","Discard"]
var current_option_selected
var current_option_number = 0
var equip_use_allowed = false

func start(item):
	visible = true
	item_selected = item
	
	equip_use_allowed = false
	
	current_option_number = 0
	current_option_selected = current_options[current_option_number]
	
	# Hand original position
	$"Hand Selector".rect_position = Vector2(-12,6)
	
	
	# Can we equip this item?
	if item.item_class == Item.ITEM_CLASS.CONSUMABLE:
		$"Box Texture/Equip".text = "Use"
		if item.can_be_consumed():
			equip_use_allowed = true
			$"Box Texture/Equip".set("custom_colors/font_color", Color(1.0, 1.0, 1.0))
		else:
			$"Box Texture/Equip".set("custom_colors/font_color", Color(0.64, 0.56, 0.56))
	else:
		$"Box Texture/Equip".text = "Equip"
		# Can we use this item?
		if item.is_usable_by_current_unit:
			equip_use_allowed = true
			$"Box Texture/Equip".set("custom_colors/font_color", Color(1.0, 1.0, 1.0))
		else:
			$"Box Texture/Equip".set("custom_colors/font_color", Color(0.64, 0.56, 0.56))
			
	$Timer.start(0)

# Input for Hand movement
func _input(event):
	if !is_active:
		return
	if Input.is_action_just_pressed("ui_accept"):
		process_selection()
	elif Input.is_action_just_pressed("ui_cancel"):
		$"Hand Selector/Cancel".play(0)
		go_back()
	elif Input.is_action_just_pressed("ui_up"):
		movement("up")
	elif Input.is_action_just_pressed("ui_down"):
		movement("down")

func movement(direction):
	match direction:
		"up":
			current_option_number -= 1
			if current_option_number < 0:
				current_option_number = 0
			else:
				$"Hand Selector".rect_position.y -= ACTION_SIZE_Y
				$"Hand Selector/Move".play(0)
			current_option_selected = current_options[current_option_number]
		"down":
			current_option_number += 1
			if current_option_number > current_options.size() - 1:
				current_option_number = current_options.size() - 1
			else:
				$"Hand Selector".rect_position.y += ACTION_SIZE_Y
				$"Hand Selector/Move".play(0)
			current_option_selected = current_options[current_option_number]

func process_selection():
	match current_option_selected:
		"Equip":
			if equip_use_allowed:
				if item_selected.item_class == Item.ITEM_CLASS.CONSUMABLE:
					$"Hand Selector/Accept".play(0)
					item_selected.use_consumable()
					go_back()
				else:
					BattlefieldInfo.current_Unit_Selected.UnitInventory.current_item_equipped = item_selected
					$"Hand Selector/Accept".play(0)
					go_back()
			else:
				$"Hand Selector/Invalid".play(0)
		"Discard":
			get_node("Yes No Box").start(item_selected)
			$"Hand Selector/Accept".play(0)
			is_active = false


func go_back():
	is_active = false
	get_parent().get_parent().start()
	
	visible = false

func turn_off():
	visible = false
	is_active = false

func turn_on():
	# Turn On
	$"Box Texture/Equip"
	
	# Turn on Input
	is_active = true

func _on_Timer_timeout():
	is_active = true
