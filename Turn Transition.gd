extends Node2D

var texture_height
var texture_width
var speed
var accel
var currentTime
var maxTime
var scaleSpeed

var enabled

# Called when the node enters the scene tree for the first time.
func _ready():
	texture_height = $"Player Turn".texture.get_height()
	texture_width = $"Player Turn".texture.get_width()
	
	speed = 150
	scaleSpeed = 0.5
	accel = 0
	maxTime = 1.5
	currentTime = 0
	enabled = false
	
	$"Timer".start(1)

func _process(delta):
	if (enabled):
		currentTime += delta
		$"Player Turn".scale.x = 1 - (currentTime * scaleSpeed)
		$"Player Turn".position.x += speed * delta 

func _on_Timer_timeout() -> void:
	enabled = true

func resetVariables() -> void:
	currentTime = 0
	$"Player Turn".scale.x = 0
	$"Player Turn".position.x = 120
	enabled = false