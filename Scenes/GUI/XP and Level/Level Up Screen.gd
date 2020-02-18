extends Node2D

# Upgrade Stats
var level_up
var str_up
var skill_up
var speed_up
var magic_up 
var luck_up 
var def_up
var res_up
var consti_up
var max_health_up

# Signal
signal done_leveling_up

# Var break
var break_time = 0

# Magic Panel
var magic_panel = preload("res://assets/UI/XP and Level/Level Up Panel Mag.png")
var str_panel = preload("res://assets/UI/XP and Level/Level Up Panel.png")

# Prevent 0 upgrades
var number_of_upgrades = 0

# Prepare random function
func _ready():
	randomize()
	$"Level Up Panel/anim".connect("animation_finished", self, "process_stat_upgrade")
	set_process(false)

func _process(delta):
	break_time += delta
	
	if break_time >= 0.2:
		if level_up == 1:
			BattlefieldInfo.combat_player_unit.UnitStats.level += level_up
			$"Level Up Panel/Level Up Background/Level/Level Arrow".visible = true
			$"Level Up Panel/Level Up Background/Level".text = str(BattlefieldInfo.combat_player_unit.UnitStats.level)
			$"Stat Up Sound".play(0)
			level_up = 0
			break_time = 0
			return
		# Check if the stat isn't higher than the max allowed then proceed
		if max_health_up == 1 && BattlefieldInfo.combat_player_unit.UnitStats.max_health < Unit_Stats.MAX_POSSIBLE_HEALTH:
			BattlefieldInfo.combat_player_unit.UnitStats.max_health += max_health_up
			BattlefieldInfo.combat_player_unit.UnitStats.current_health += 1
			$"Level Up Panel/Level Up Background/HP".text = str(BattlefieldInfo.combat_player_unit.UnitStats.max_health)
			$"Level Up Panel/Level Up Background/HP/HP Arrow".visible = true
			max_health_up = 0
			break_time = 0
			return
		if str_up == 1 && BattlefieldInfo.combat_player_unit.UnitStats.strength < Unit_Stats.MAX_STAT:
			BattlefieldInfo.combat_player_unit.UnitStats.strength += str_up
			$"Level Up Panel/Level Up Background/Str".text = str(BattlefieldInfo.combat_player_unit.UnitStats.strength)
			$"Level Up Panel/Level Up Background/Str/Str Arrow".visible = true
			$"Stat Up Sound".play(0)
			str_up = 0
			break_time = 0
			return
		if magic_up == 1 && BattlefieldInfo.combat_player_unit.UnitStats.magic < Unit_Stats.MAX_STAT:
			BattlefieldInfo.combat_player_unit.UnitStats.magic += magic_up
			$"Level Up Panel/Level Up Background/Str".text = str(BattlefieldInfo.combat_player_unit.UnitStats.magic)
			$"Level Up Panel/Level Up Background/Str/Str Arrow".visible = true
			$"Stat Up Sound".play(0)
			magic_up = 0
			break_time = 0
			return
		if skill_up == 1 && BattlefieldInfo.combat_player_unit.UnitStats.skill < Unit_Stats.MAX_STAT:
			BattlefieldInfo.combat_player_unit.UnitStats.skill += skill_up
			$"Level Up Panel/Level Up Background/Skill".text = str(BattlefieldInfo.combat_player_unit.UnitStats.skill)
			$"Level Up Panel/Level Up Background/Skill/Skill Arrow".visible = true
			$"Stat Up Sound".play(0)
			skill_up = 0
			break_time = 0
			return
		if speed_up == 1 && BattlefieldInfo.combat_player_unit.UnitStats.speed < Unit_Stats.MAX_STAT:
			BattlefieldInfo.combat_player_unit.UnitStats.speed += speed_up
			$"Level Up Panel/Level Up Background/Spd".text = str(BattlefieldInfo.combat_player_unit.UnitStats.speed)
			$"Level Up Panel/Level Up Background/Spd/Spd Arrow".visible = true
			$"Stat Up Sound".play(0)
			speed_up = 0
			break_time = 0
			return
		if luck_up == 1 && BattlefieldInfo.combat_player_unit.UnitStats.luck < Unit_Stats.MAX_STAT:
			BattlefieldInfo.combat_player_unit.UnitStats.luck += luck_up
			$"Level Up Panel/Level Up Background/Luck".text = str(BattlefieldInfo.combat_player_unit.UnitStats.luck)
			$"Level Up Panel/Level Up Background/Luck/Luck Arrow".visible = true
			$"Stat Up Sound".play(0)
			luck_up = 0
			break_time = 0
			return
		if def_up == 1 && BattlefieldInfo.combat_player_unit.UnitStats.def < Unit_Stats.MAX_STAT:
			BattlefieldInfo.combat_player_unit.UnitStats.def += def_up
			$"Level Up Panel/Level Up Background/Def".text = str(BattlefieldInfo.combat_player_unit.UnitStats.def)
			$"Level Up Panel/Level Up Background/Def/Def Arrow".visible = true
			$"Stat Up Sound".play(0)
			def_up = 0
			break_time = 0
			return
		if res_up == 1 && BattlefieldInfo.combat_player_unit.UnitStats.res < Unit_Stats.MAX_STAT:
			BattlefieldInfo.combat_player_unit.UnitStats.res += res_up
			$"Level Up Panel/Level Up Background/Res".text = str(BattlefieldInfo.combat_player_unit.UnitStats.res)
			$"Level Up Panel/Level Up Background/Res/Res Arrow".visible = true
			$"Stat Up Sound".play(0)
			res_up = 0
			break_time = 0
			return
		if consti_up == 1 && BattlefieldInfo.combat_player_unit.UnitStats.consti < Unit_Stats.MAX_STAT:
			BattlefieldInfo.combat_player_unit.UnitStats.consti += consti_up
			$"Level Up Panel/Level Up Background/Con".text = str(BattlefieldInfo.combat_player_unit.UnitStats.consti)
			$"Level Up Panel/Level Up Background/Con/Con Arrow".visible = true
			$"Stat Up Sound".play(0)
			consti_up = 0
			break_time = 0
			return
			
		# Exit if we reach here
		set_process(false)
		$Return.start(0)

func start():
	# Reset
	level_up = 0
	max_health_up = 0
	str_up = 0
	skill_up = 0
	speed_up = 0
	magic_up = 0
	luck_up = 0
	def_up = 0
	res_up = 0
	consti_up = 0
	number_of_upgrades = 0

	break_time = 0
	
	get_stat_upgrades()
	
	$"Show Pause".start(0)
	
	# Set Text and Mugshot
	$"Level Up Panel/Level Up Background/Class".text = BattlefieldInfo.combat_player_unit.UnitStats.class_type
	$"Level Up Panel/Level Up Background/Level".text = str(BattlefieldInfo.combat_player_unit.UnitStats.level)
	$"Level Up Panel/Level Up Background/HP".text = str(BattlefieldInfo.combat_player_unit.UnitStats.max_health)
	$"Level Up Panel/Level Up Background/Luck".text = str(BattlefieldInfo.combat_player_unit.UnitStats.luck)
	
	if BattlefieldInfo.combat_player_unit.UnitStats.strength > BattlefieldInfo.combat_player_unit.UnitStats.magic:
		$"Level Up Panel/Level Up Background/Str".text = str(BattlefieldInfo.combat_player_unit.UnitStats.strength)
		$"Level Up Panel/Level Up Background".texture =  str_panel
	else:
		$"Level Up Panel/Level Up Background/Str".text = str(BattlefieldInfo.combat_player_unit.UnitStats.magic)
		$"Level Up Panel/Level Up Background".texture = magic_panel
	$"Level Up Panel/Level Up Background/Def".text = str(BattlefieldInfo.combat_player_unit.UnitStats.def)
	$"Level Up Panel/Level Up Background/Skill".text = str(BattlefieldInfo.combat_player_unit.UnitStats.skill)
	$"Level Up Panel/Level Up Background/Res".text = str(BattlefieldInfo.combat_player_unit.UnitStats.res)
	$"Level Up Panel/Level Up Background/Spd".text = str(BattlefieldInfo.combat_player_unit.UnitStats.speed)
	$"Level Up Panel/Level Up Background/Con".text = str(BattlefieldInfo.combat_player_unit.UnitStats.consti)
	
	$"Level Up Panel/Unit Mugshot".texture = BattlefieldInfo.combat_player_unit.unit_mugshot

func dissolve_level_up_logo():
	$"Level Up Logo".material.set_shader_param("duration", 1.5)
	$"Level Up Logo".material.set_shader_param("start_time", OS.get_ticks_msec() / 1000.0)

func play_sound_and_graphic():
	# Play fade in
	$"Level Up Logo/anim".play("fade in")
	
	# Set Graphic here
	$"Level Up Sound".play(0)
	dissolve_level_up_logo()
	
	$"Bring Panel Up".start(0)

func get_stat_upgrades():
	var unit_stat = BattlefieldInfo.combat_player_unit.UnitStats
	level_up = 1
	
	str_up = int(hit_occured(unit_stat.str_chance))
	skill_up = int(hit_occured(unit_stat.skill_chance))
	speed_up = int(hit_occured(unit_stat.speed_chance))
	magic_up = int(hit_occured(unit_stat.magic_chance))
	luck_up = int(hit_occured(unit_stat.luck_chance))
	def_up = int(hit_occured(unit_stat.def_chance))
	consti_up = int(hit_occured(unit_stat.consti_chance))
	max_health_up = int(hit_occured(unit_stat.max_health_chance))
	
	# Check if we have any upgrades
	number_of_upgrades = str_up + skill_up + speed_up + magic_up + luck_up + def_up + consti_up + max_health_up
	
	# Do we have nothing? Always give HP if 0
	if number_of_upgrades == 0:
		max_health_up = 1

func hit_occured(chance):
	if chance <= 0:
		return false
	elif chance >= 100:
		return true
	
	return int(rand_range(0,100)) <= chance

func _on_Return_timeout():
	set_process(false)
	
	# Turn off
	$"Level Up Logo".visible = false
	$"Level Up Panel".visible = false
	$"Level Up Panel/Level Up Background/Level/Level Arrow".visible = false
	$"Level Up Panel/Level Up Background/HP/HP Arrow".visible = false
	$"Level Up Panel/Level Up Background/Str/Str Arrow".visible = false
	$"Level Up Panel/Level Up Background/Skill/Skill Arrow".visible = false
	$"Level Up Panel/Level Up Background/Spd/Spd Arrow".visible = false
	$"Level Up Panel/Level Up Background/Luck/Luck Arrow".visible = false
	$"Level Up Panel/Level Up Background/Def/Def Arrow".visible = false
	$"Level Up Panel/Level Up Background/Spd/Spd Arrow".visible = false
	$"Level Up Panel/Level Up Background/Def/Def Arrow".visible = false
	$"Level Up Panel/Level Up Background/Res/Res Arrow".visible = false
	$"Level Up Panel/Level Up Background/Con/Con Arrow".visible = false
	
	# Set to greyscale
	BattlefieldInfo.combat_player_unit.get_node("Animation").play("Idle")
	BattlefieldInfo.combat_player_unit.UnitActionStatus.current_action_status = Unit_Action_Status.DONE
	BattlefieldInfo.combat_player_unit.turn_greyscale_on()
	
	# Broken weapon screen
	if get_parent().get_parent().get_parent().broke_item:
		get_parent().get_node("Item Broke Screen").start(BattlefieldInfo.combat_player_unit.UnitInventory.current_item_equipped, BattlefieldInfo.combat_player_unit)
	else:
		emit_signal("done_leveling_up")

# Half second pause
func _on_Show_Pause_timeout():
	play_sound_and_graphic()

# Bring panel up
func _on_Bring_Panel_Up_timeout():
	$"Level Up Panel/anim".play("fade in")

func process_stat_upgrade(anim_name):
	set_process(true)
