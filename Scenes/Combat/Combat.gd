extends CanvasLayer

var combat_system

func _ready():
	combat_system = Combat_System.new()
	
	BattlefieldInfo.music_player.get_node("Ally Combat").play(0)

func _input(event):
	if Input.is_action_just_pressed("debug"):
		$"Eirika Combat/anim".play("regular")
	

func play_draw_sound_player():
	# Get weapon type and play appropriate sound
	pass

func play_draw_sound_enemy():
	pass

func play_put_away_player():
	pass

func play_put_away_enemy():
	pass