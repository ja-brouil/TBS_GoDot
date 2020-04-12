extends Node2D

onready var music = $"BG Music"
onready var eirika_walk = $"YSort/Eirika Walk"

func _ready():
	music.play(0)
	
	# Add to battlefield info
	BattlefieldInfo.walkable_map = self
