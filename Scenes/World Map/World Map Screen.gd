extends Node2D

# The world map which is shown in between chapters

func _ready():
	SceneTransition.connect("scene_changed", self, "start")

func start():
	pass