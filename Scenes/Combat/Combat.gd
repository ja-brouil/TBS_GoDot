extends CanvasLayer

# Nodes
var player_node_name
var enemy_node_name

# Backgrounds
var plain = preload("res://assets/UI/combatUI/Plains.png")
var forest = preload("res://assets/UI/combatUI/Forest.png")
var fortress = preload("res://assets/UI/combatUI/Fortress.png")
var mountain = preload("res://assets/UI/combatUI/Mountain.png")
var river = preload("res://assets/UI/combatUI/River.png")
var sea = preload("res://assets/UI/combatUI/Sea.png")
var village = preload("res://assets/UI/combatUI/Village.png")

# Combat Process
func start_combat(): 
	# Process actual numbers
	Combat_Calculator.process_player_combat()
	Combat_Calculator.process_enemy_combat()
	
	# Tint background
	get_parent().get_node("YSort/Combat Tint").visible = true
	
	# Place appropriate combat art
	place_combat_art()
	
	# Adjust GUI Box
	adjust_gui_text_and_hp_box()
	
	# Set Background
	set_background(BattlefieldInfo.combat_player_unit.UnitMovementStats.currentTile.tileName)
	
	# Turn on
	turn_on()
	
	# Attack whoever is first
	var ally = true # placeholder
	process_first_attack(ally)
	
	# If not dead and able to counter attack
	var enemy = true # placeholder
	process_first_attack(enemy)

# Get the appropriate art
func place_combat_art():
	# Player
	player_node_name = BattlefieldInfo.combat_player_unit.combat_node.instance()
	player_node_name.position = $"Ally Unit".position
	add_child(player_node_name)
	
	# Enemy
	enemy_node_name = BattlefieldInfo.combat_ai_unit.combat_node.instance()
	enemy_node_name.position = $"Enemy Unit".position
	add_child(enemy_node_name)

# Set appropriate text
func adjust_gui_text_and_hp_box():
	# Player
	$"Combat Control/Combat UI/Player/Player Name".text = BattlefieldInfo.combat_player_unit.UnitStats.name
	$"Combat Control/Combat UI/Player/Player HP Number".text = str(BattlefieldInfo.combat_player_unit.UnitStats.current_health)
	$"Combat Control/Combat UI/Player/Player Hit".text = str(Combat_Calculator.player_accuracy)
	$"Combat Control/Combat UI/Player/Player Dmg".text = str(Combat_Calculator.player_damage)
	$"Combat Control/Combat UI/Player/Player Weapon Name".text = BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped.item_name
	
	# Set player rect %
	$"Combat Control/Combat UI/Player/Player Full HP".region_rect = Rect2(0, 0, 273 * \
	(float(BattlefieldInfo.combat_player_unit.UnitStats.current_health) / float(BattlefieldInfo.combat_player_unit.UnitStats.max_health)), \
	37)
	
	# Enemy
	$"Combat Control/Combat UI/Enemy/Enemy Name".text = BattlefieldInfo.combat_ai_unit.UnitStats.name
	$"Combat Control/Combat UI/Enemy/Enemy HP Number".text = str(BattlefieldInfo.combat_ai_unit.UnitStats.current_health)
	$"Combat Control/Combat UI/Enemy/Enemy Hit".text = str(Combat_Calculator.enemy_accuracy)
	$"Combat Control/Combat UI/Enemy/Enemy Dmg".text = str(Combat_Calculator.enemy_damage)
	$"Combat Control/Combat UI/Enemy/Enemy Weapon Name".text = BattlefieldInfo.combat_ai_unit.UnitInventory.current_item_equipped.item_name
	
	# Set enemy rect %
	$"Combat Control/Combat UI/Enemy/Enemy Full HP".region_rect = Rect2(0, 0, 273 * \
	(float(BattlefieldInfo.combat_ai_unit.UnitStats.current_health) / float(BattlefieldInfo.combat_ai_unit.UnitStats.max_health)), \
	37)

# Set Appropriate background
func set_background(tilename):
	match tilename:
		"Plain":
			$"Combat Control/Background".texture = plain
		"Forest":
			$"Combat Control/Background".texture = forest
		"Fortress":
			$"Combat Control/Background".texture = fortress
		"Mountain" || "Hill":
			$"Combat Control/Background".texture = mountain
		"River":
			$"Combat Control/Background".texture = river
		"Sea":
			$"Combat Control/Background".texture = sea
		"Village":
			$"Combat Control/Background".texture = village
		_: # Fall back -> add more later
			$"Combat Control/Background".texture = plain

func process_first_attack(unit):
	print("Combat processsed")
	player_node_name.get_node("anim").play("sword regular")
	$Timer.start(0)
	# Check if miss/crit/hit
	# play appropariate animations
	# play appropriate sound effects
	# update damage
	# update world
	# return to map

func turn_on():
	$"Combat Control".visible = true
	# Stop current music
	if BattlefieldInfo.turn_manager.turn == Turn_Manager.PLAYER_TURN:
		BattlefieldInfo.music_player.get_node("AllyLevel").stop()
	else:
		BattlefieldInfo.music_player.get_node("EnemyLevel").stop()
	
	# Start music
	if BattlefieldInfo.turn_manager.turn == Turn_Manager.PLAYER_TURN:
		BattlefieldInfo.music_player.get_node("Ally Combat").play(0)
	else:
		BattlefieldInfo.music_player.get_node("Enemy Combat").play(0)

func turn_off():
	# Stop Music
	if BattlefieldInfo.turn_manager.turn == Turn_Manager.PLAYER_TURN:
		BattlefieldInfo.music_player.get_node("Ally Combat").stop()
	else:
		BattlefieldInfo.music_player.get_node("Enemy Combat").stop()

# TEST
func _on_Timer_timeout():
	# REMOVE OLD STUFF
	player_node_name.queue_free()
	enemy_node_name.queue_free()
	
	turn_off()
