extends CanvasLayer

# Unit Info Screen to get more info on a unit
var input_is_active = false

var item_slots = []

func _ready():
	BattlefieldInfo.unit_info_screen = self

func build_info_sheet():
	# Cache unit
	var current_unit = BattlefieldInfo.current_Unit_Selected
	
	# Reduce volume
	BattlefieldInfo.music_player.get_node("AllyLevel").volume_db = -8
	
	# Unit Portrait
	$"Unit Info Container/Portrait and Name Container/Portrait".texture = current_unit.unit_portrait_path
	
	# Unit Name and numbers
	$"Unit Info Container/Portrait and Name Container/Name".text = current_unit.UnitStats.name
	$"Unit Info Container/Portrait and Name Container/Class".text = current_unit.UnitStats.class_type
	$"Unit Info Container/Portrait and Name Container/Level Number".text = str(current_unit.UnitStats.level)
	$"Unit Info Container/Portrait and Name Container/Exp num".text = str(current_unit.UnitStats.current_xp)
	$"Unit Info Container/Portrait and Name Container/Current HP".text = str(current_unit.UnitStats.current_health)
	$"Unit Info Container/Portrait and Name Container/Max HP".text = str(current_unit.UnitStats.max_health)
	
	# Stats
	if current_unit.UnitStats.strength > current_unit.UnitStats.magic:
		$"Unit Info Container/Inventory/Stats/Str Mag".text = "Str"
		$"Unit Info Container/Inventory/Stats/Str Mag Num".text = str(current_unit.UnitStats.strength)
	else:
		$"Unit Info Container/Inventory/Stats/Str Mag".text = "Mag"
		$"Unit Info Container/Inventory/Stats/Str Mag Num".text = str(current_unit.UnitStats.magic)
	$"Unit Info Container/Inventory/Stats/Def Num".text = str(current_unit.UnitStats.def)
	$"Unit Info Container/Inventory/Stats/Res Num".text = str(current_unit.UnitStats.res)
	$"Unit Info Container/Inventory/Stats/Move Num".text = str(current_unit.UnitMovementStats.movementSteps)
	$"Unit Info Container/Inventory/Stats/Con Num".text = str(current_unit.UnitStats.consti)
	$"Unit Info Container/Inventory/Stats/Skill Num".text = str(current_unit.UnitStats.skill)
	$"Unit Info Container/Inventory/Stats/Spd Num".text = str(current_unit.UnitStats.speed)
	$"Unit Info Container/Inventory/Stats/Luck Num".text = str(current_unit.UnitStats.luck)
	
	# Reset the item slots
	reset_item_slots()
	
	# Set the items that the unit has
	set_items(current_unit)
	
	# Activate
	$"Unit Info Container/Anim".play("Fade")
	$Timer.start(0)

func _input(event):
	if !input_is_active:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		turn_off()

func reset_item_slots():
	# Clear the array and gather all the slots back
	item_slots.clear()
	item_slots.append($"Unit Info Container/Inventory/Item Slot Container/Item Slot 1")
	item_slots.append($"Unit Info Container/Inventory/Item Slot Container/Item Slot 2")
	item_slots.append($"Unit Info Container/Inventory/Item Slot Container/Item Slot 3")
	item_slots.append($"Unit Info Container/Inventory/Item Slot Container/Item Slot 4")
	item_slots.append($"Unit Info Container/Inventory/Item Slot Container/Item Slot 5")
	item_slots.append($"Unit Info Container/Inventory/Item Slot Container/Item Slot 6")
	
	# Set everything to empty
	for item_slot in item_slots:
		item_slot.empty_slot()

func set_items(unit):
	for item in unit.UnitInventory.inventory:
		item_slots.pop_front().start(item)

func turn_on():
	$"Unit Info Container".visible = true
	build_info_sheet()

func turn_off():
	BattlefieldInfo.music_player.get_node("AllyLevel").volume_db = 0
	input_is_active = false
	$"Unit Info Container/Anim".play_backwards("Fade")
	yield($"Unit Info Container/Anim","animation_finished")
	$"Unit Info Container".visible = false
	
	BattlefieldInfo.cursor.back_to_move()
	BattlefieldInfo.cursor.emit_signal("turn_on_ui")
	

func _on_Timer_timeout():
	input_is_active = true
