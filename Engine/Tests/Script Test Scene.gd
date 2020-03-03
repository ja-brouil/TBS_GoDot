extends Control

func _ready():
	pass

func _input(event):
	if Input.is_action_just_pressed("debug"):
		
		var save_game = File.new()
		
		save_game.open("res://Save/savegame.save", File.WRITE)
			
		save_game.close()
