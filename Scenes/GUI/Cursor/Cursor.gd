extends Node2D

# Signal for camera and other UI elements to update
signal cursorMoved

func _ready():
	# Start cursor animation
	$"AnimatedCursor/AnimationPlayer".play("Moving")
	
# warning-ignore:unused_argument
func _input(event):
	
	# Move Cursor by x pixels
	if Input.is_action_pressed("ui_left"):
		self.position.x -= Cell.CELL_SIZE
		updateCursorData()
		emit_signal("cursorMoved", "left", self.position)
	elif Input.is_action_pressed("ui_right"):
		self.position.x += Cell.CELL_SIZE
		updateCursorData()
		emit_signal("cursorMoved", "right", self.position)
	elif Input.is_action_pressed("ui_down"):
		self.position.y += Cell.CELL_SIZE
		updateCursorData()
		emit_signal("cursorMoved", "down", self.position)
	elif Input.is_action_pressed("ui_up"):
		self.position.y -= Cell.CELL_SIZE
		updateCursorData()
		emit_signal("cursorMoved", "up", self.position)
	
	if event is InputEventKey:
		pass
#		debug()

func updateCursorData():
	# Clamp the cursor
	self.position.x = clamp(self.position.x, 0, (get_parent().get_node("Level").map_height * Cell.CELL_SIZE) - (Cell.CELL_SIZE * 3))
	self.position.y = clamp(self.position.y, 0, (get_parent().get_node("Level").map_width * Cell.CELL_SIZE) - Cell.CELL_SIZE)
	
#	# check the cursor data against the cell data
	for celldata in get_parent().get_node("Level").all_map_cell_info:
		if celldata.getPosition().x == self.position.x / Cell.CELL_SIZE:
			if celldata.getPosition().y == self.position.y / Cell.CELL_SIZE:
				#print(celldata.toString())
				if celldata.occupyingUnit:
					print("Occupied")


func debug():
	print("Cursor is at: ", self.position)