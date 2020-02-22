extends Control

var bf = BattlefieldInfo
var next = "res://Engine/Tests/Script Test Scene 2.tscn"

func _ready():
	# BattlefieldInfo.clear()
	
	BattlefieldInfo.battlefield_container = self

func _input(event):
	if Input.is_action_just_pressed("debug"):
		print(bf)
	
	if Input.is_action_just_pressed("L button"):
		SceneTransition.change_scene(next, 0.1)
