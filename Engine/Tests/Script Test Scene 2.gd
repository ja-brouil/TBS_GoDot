extends Control

var bf = BattlefieldInfo
var next = "res://Engine/Tests/Script Test Scene.tscn"

func _ready():
	#BattlefieldInfo.clear()
	
	BattlefieldInfo.battlefield_container = self

func _input(event):
	if Input.is_action_just_pressed("debug"):
		print(bf)
	
	if Input.is_action_just_pressed("L button"):
		SceneTransition.change_scene_to(WorldMapScreen, 0.1)