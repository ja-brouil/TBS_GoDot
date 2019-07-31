extends Node2D

func _ready():
	# Start cursor animation
	$"AnimatedCursor/AnimationPlayer".play("Moving")
	
func _input(event):
	# Move Cursor by x pixels
	if Input.is_action_pressed("ui_left"):
		self.position.x -= Cell.CELL_SIZE
	elif Input.is_action_pressed("ui_right"):
		self.position.x += Cell.CELL_SIZE
	elif Input.is_action_pressed("ui_down"):
		self.position.y += Cell.CELL_SIZE
	elif Input.is_action_pressed("ui_up"):
		self.position.y -= Cell.CELL_SIZE
		
func _process(delta):
	pass