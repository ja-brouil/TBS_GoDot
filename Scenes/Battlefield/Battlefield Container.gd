extends Node2D

var level_music = preload("res://assets/music/Chasing Daybreak.ogg")

func _ready():
	BattlefieldInfo.battlefield_container = self
	
	# Set Music
	BattlefieldInfo.music_player.get_node("AllyLevel").stream = level_music
	
	# Set victory condition
	BattlefieldInfo.victory = false
	BattlefieldInfo.victory_system.clear()
	BattlefieldInfo.victory_system.victory_condition_state = Victory_Checker.SURVIVE
	BattlefieldInfo.victory_system.turns_left_to_survive = 10
	
	# Start the level
	$"Event System".start_events_queue()

func check_loss():
	return BattlefieldInfo.ally_units.has("Seth")

func next_level():
	pass