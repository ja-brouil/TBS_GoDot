extends Control

# Show the your item broke sreen
signal exit

func start(item, battlefield_unit):
	# Lower volume of the music
	if BattlefieldInfo.turn_manager.turn == Turn_Manager.ENEMY_TURN:
		BattlefieldInfo.music_player.get_node("Enemy Combat").volume_db = -12
	else:
		BattlefieldInfo.music_player.get_node("Ally Combat").volume_db = -12
	
	# Set icon
	$"Item Broke Box/item icon".texture = item.icon
	
	# Set text
	$"Item Broke Box/item name".text = item.item_name
	
	# Show panel
	visible = true
	
	# Play sound
	$"Item Broke Sound".play(0)
	
	# Remove item from inventory
	battlefield_unit.UnitInventory.remove_item(item)
	
	# Exit
	$Exit.start(0)

func turn_off():
	visible = false
	emit_signal("exit")

func _on_Exit_timeout():
	if BattlefieldInfo.turn_manager.turn == Turn_Manager.ENEMY_TURN:
		BattlefieldInfo.music_player.get_node("Enemy Combat").volume_db = 0
	else:
		BattlefieldInfo.music_player.get_node("Ally Combat").volume_db = 0
	
	get_parent().get_parent().get_parent().broke_item = false
	get_parent().get_node("Level Up Screen").emit_signal("done_leveling_up")