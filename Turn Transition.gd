extends Node2D

var texture_height
var texture_width
var speed
var accel
var currentTime
var maxTime

# Called when the node enters the scene tree for the first time.
func _ready():
	texture_height = $"Player Turn".texture.get_height()
	texture_width = $"Player Turn".texture.get_width()
	
	print(texture_height, " " , texture_width)
	
	speed = 100
	accel = 0
	maxTime = 1.5
	currentTime = 0

func _process(delta):
	if (currentTime < maxTime):
		currentTime += delta
		
		$"Player Turn".scale.x = 1 - ((currentTime / maxTime))
		$"Player Turn".position.x += speed * delta 