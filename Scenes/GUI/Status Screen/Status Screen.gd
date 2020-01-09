extends CanvasLayer

# Full Bar constant for math
const full_bar_width = 237

# Play Time
var time_start = 0
var time_now = 0

func _ready():
	set_process_input(false)
	
	# Play Time
	time_start = OS.get_unix_time()
	set_process(true)

func _process(delta):
	# Time Played
	time_now = OS.get_unix_time()
	var elapsed = time_now - time_start
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var str_elapsed =  "%02d : %02d" % [minutes, seconds]
	
	# Set Time Played
	$"UI/Time Played/Time".text = str_elapsed

# Call to start this screen
func start():
	# Set Info
	set_screen()
	
	# Play animation
	$Anim.play("Fade")
	yield($Anim, "animation_finished")
	
	# Allow input
	set_process_input(true)

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		set_process_input(false)
		
		$Anim.play_backwards("Fade")
		yield($Anim, "animation_finished")
		
		# Head back
		BattlefieldInfo.cursor.back_to_move()
		BattlefieldInfo.cursor.emit_signal("turn_on_ui")

# Set the appropriate graphics and text
func set_screen():
	# Set Title chapter
	$"UI/Chapter Title".text = BattlefieldInfo.battlefield_container.chapter_title
	
	# Set Eirika
	$UI/Eirika/Name.text = BattlefieldInfo.Eirika.UnitStats.name
	calculate_health_values(BattlefieldInfo.Eirika, get_node("UI/Eirika"))
	
	# Set Enemy commander
	$"UI/Enemy Commander/Name".text = BattlefieldInfo.enemy_commander.UnitStats.name
	calculate_health_values(BattlefieldInfo.enemy_commander, get_node("UI/Enemy Commander"))
	
	# Set Number for players
	$"UI/Player Units/ColorRect/Number".text = str(BattlefieldInfo.ally_units.size())
	
	# Set Number for enemies
	$UI/Enemy/ColorRect/Number.text = str(BattlefieldInfo.enemy_units.size())
	
	# Objective
	$"UI/Objective/Objective Desc".text = BattlefieldInfo.victory_text
	
	# Turn
	$"UI/Objective/Turn Number".text = str(BattlefieldInfo.turn_manager.player_turn_number)
	
	# Money
	$"UI/Objective/Money Amt".text = str(BattlefieldInfo.money, " G")

func calculate_health_values(unit, node_name):
	# Set Health Text
	node_name.get_node("Health").text = str(unit.UnitStats.current_health, " / ", unit.UnitStats.max_health)
	
	# Set Percentage for drawing the box
	node_name.get_node("Full HP").region_rect = Rect2(0, 0, full_bar_width * (float(unit.UnitStats.current_health) / float(unit.UnitStats.max_health)), 17)
	
	# Set Portrait
	node_name.get_node("Portrait").texture = unit.unit_portrait_path