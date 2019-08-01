extends Node2D

# Signal for camera and other UI elements to update
signal cursorMoved

# Clamping

func _ready():
	# Start cursor animation
	$"AnimatedCursor/AnimationPlayer".play("Moving")
	
# warning-ignore:unused_argument
func _input(event):
	
	# Move Cursor by x pixels
	if Input.is_action_pressed("ui_left"):
		self.position.x -= Cell.CELL_SIZE
		emit_signal("cursorMoved", "left", self.position)
	elif Input.is_action_pressed("ui_right"):
		self.position.x += Cell.CELL_SIZE
		emit_signal("cursorMoved", "right", self.position)
	elif Input.is_action_pressed("ui_down"):
		self.position.y += Cell.CELL_SIZE
		emit_signal("cursorMoved", "down", self.position)
	elif Input.is_action_pressed("ui_up"):
		self.position.y -= Cell.CELL_SIZE
		emit_signal("cursorMoved", "up", self.position)
	
	# Prevent the cursor from going out of bounds
	preventOutOfBounds()
	
	#debug()

func preventOutOfBounds():
	self.position.x = clamp(self.position.x, 0, get_parent().get_node("Level").map_width * Cell.CELL_SIZE)
	self.position.y = clamp(self.position.y, 0, get_parent().get_node("Level").map_height * Cell.CELL_SIZE)
	

func debug():
	print(self.position)