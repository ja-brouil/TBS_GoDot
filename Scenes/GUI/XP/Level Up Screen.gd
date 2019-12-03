extends Control

# Upgrade Stats
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

# Prepare random function
func _ready():
	randomize()

# List of things that need to be done
# Roll dice for stat upgrades
# Add said points
# Return to the world map once done

func start():
	# Reset
	str_up = 0
	skill_up = 0
	speed_up = 0
	magic_up = 0
	luck_up = 0
	def_up = 0
	res_up = 0
	consti_up = 0
	max_health_up = 0
	
	play_sound_and_graphic()
	get_stat_upgrades()
	
	# Need some type of pause here
	# Check if the stat isn't higher than the max allowed then proceed
	print("Stats Upgrades this time were ")
	if str_up == 1:
		print("STR UP")
	if skill_up == 1:
		print("SKILL UP")
	if speed_up == 1:
		print("SPEED UP")
	if magic_up == 1:
		print("MAGIC UP")
	if luck_up == 1:
		print("LUCK UP")
	if def_up == 1:
		print("DEF UP")
	if consti_up == 1:
		print("CONSTI UP")
	if max_health_up == 1:
		print("MAX HP UP")
		# Increase current hp by 1 as well
	
	$Return.start(0)


func play_sound_and_graphic():
	# Set Graphic here
	$"Level Up Sound".play(0)

func get_stat_upgrades():
	var unit_stat = BattlefieldInfo.combat_player_unit.UnitStats
	str_up = int(hit_occured(unit_stat.str_chance))
	skill_up = int(hit_occured(unit_stat.skill_chance))
	speed_up = int(hit_occured(unit_stat.speed_chance))
	magic_up = int(hit_occured(unit_stat.magic_chance))
	luck_up = int(hit_occured(unit_stat.magic_chance))
	def_up = int(hit_occured(unit_stat.magic_chance))
	consti_up = int(hit_occured(unit_stat.magic_chance))
	max_health_up = int(hit_occured(unit_stat.magic_chance))

func hit_occured(chance):
	if chance <= 0:
		return false
	elif chance >= 100:
		return true
	
	return int(rand_range(0,100)) <= chance

func _on_Return_timeout():
	# Set Correct Volumes again
	if BattlefieldInfo.turn_manager.turn == Turn_Manager.ENEMY_TURN:
		BattlefieldInfo.music_player.get_node("Enemy Combat").volume_db = 0
	else:
		BattlefieldInfo.music_player.get_node("Ally Combat").volume_db = 0
	emit_signal("done_leveling_up")
	