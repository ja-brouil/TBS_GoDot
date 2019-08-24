extends Node2D

# Signal for camera and other UI elements to update
signal cursorMoved

# Turn off UI elements when the unit starts moving
signal turn_off_ui
signal turn_on_ui

# Holds current unit selected
var currentUnit

# Which mode is the cursor in
enum {MOVE, SELECT_MOVE_TILE, SELECT_ATTACK_TILE, SELECT_HEAL_TILE, SELECT_SPECIAL_TILE}
var cursor_state

func _ready():
	# Start cursor animation
	$"AnimatedCursor/AnimationPlayer".play("Moving")
	
	# Intial enum
	cursor_state = MOVE
	
# warning-ignore:unused_argument
func _input(event):
	# Move Cursor by x pixels
	if Input.is_action_pressed("ui_left"):
		self.position.x -= Cell.CELL_SIZE
		updateCursorData()
		$"MoveSound".play()
		emit_signal("cursorMoved", "left", self.position)
	elif Input.is_action_pressed("ui_right"):
		self.position.x += Cell.CELL_SIZE
		updateCursorData()
		$"MoveSound".play()
		emit_signal("cursorMoved", "right", self.position)
	elif Input.is_action_pressed("ui_down"):
		self.position.y += Cell.CELL_SIZE
		updateCursorData()
		$"MoveSound".play()
		emit_signal("cursorMoved", "down", self.position)
	elif Input.is_action_pressed("ui_up"):
		self.position.y -= Cell.CELL_SIZE
		updateCursorData()
		$"MoveSound".play()
		emit_signal("cursorMoved", "up", self.position)
	elif Input.is_action_just_pressed("ui_accept"):
		acceptButton()
	elif Input.is_action_just_pressed("ui_cancel"):
		cancel_Button()
	
	if Input.is_action_just_pressed("debug"):
		debug()


func updateCursorData() -> void:
	# Clamp the cursor
	self.position.x = clamp(self.position.x, 0, (get_parent().get_node("Level").map_height * Cell.CELL_SIZE) - (Cell.CELL_SIZE * 3))
	self.position.y = clamp(self.position.y, 0, (get_parent().get_node("Level").map_width * Cell.CELL_SIZE) - Cell.CELL_SIZE)
	
	# Move Mode
	match cursor_state:
		MOVE:
			# Set Animation status of unit if not null -> This is if you go from one cell to another and both are adj and occupied
			if currentUnit != null:
					currentUnit.get_node("Animation").animation = "Idle"
					currentUnit = null
					set_animation_status(true)
					# Remove Global Unit
					get_parent().set_Current_Unit_Selected(null)
			
			# check if the cell if occupied
			if get_parent().get_node("Level").grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit != null:
				currentUnit = get_parent().get_node("Level").grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit
				
				# Set Global Variable
				get_parent().set_Current_Unit_Selected(get_parent().get_node("Level").grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit)
				
				# Check if this unit is an ally
				if currentUnit.UnitMovementStats.is_ally && currentUnit.UnitActionStatus.get_current_action() != Unit_Action_Status.DONE:
					currentUnit.get_node("Animation").animation = "Selected"
				
				# Stop Cursor animation
				set_animation_status(false)
			else:
				# Do we have a unit selected right now?
				if currentUnit != null:
					currentUnit.get_node("Animation").animation = "Idle"
					currentUnit = null
					
					# Remove Global Unit
					get_parent().set_Current_Unit_Selected(null)
					
					# Start animation of the cursor again
					set_animation_status(true)
		

# Accept Button
func acceptButton() -> void:
	match cursor_state:
		MOVE:
		# Open end turn window # Send a signal out here -> Or if you pressed a unit that is done
			if get_parent().get_node("Level").grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit == null || currentUnit.UnitActionStatus.get_current_action() == Unit_Action_Status.DONE:
				print("End turn menu was pressed")
				return
			
			# Set current unit to the global unit selector
			get_parent().set_Current_Unit_Selected(currentUnit)
			
			# Set Selected Animation to current unit
			if currentUnit.UnitMovementStats.is_ally:
				currentUnit.get_node("Animation").animation = "Highlighted"
			
			# Highlight ranges
			get_parent().movement_calculator.calculatePossibleMoves(get_parent().get_node("Level").grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit, get_parent().get_node("Level").grid)
			
			# Set Cursor to the move status
			cursor_state = SELECT_MOVE_TILE
			
			# Set animation back to true
			set_animation_status(true)
			
			# Sound
			$"SelectUnitSound".play()
			
			# Turn off UI
			emit_signal("turn_off_ui")
			
		SELECT_MOVE_TILE:
			# Validate that this is an ally
			if !currentUnit.UnitMovementStats.is_ally:
				cancel_Button()
				return
			
			# Validate if tile is in the list
			if get_parent().movement_calculator.check_if_move_is_valid(get_parent().get_node("Level").grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE], currentUnit):
				
				# Get the path to the tile
				get_parent().movement_calculator.get_path_to_destination(currentUnit, get_parent().get_node("Level").grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE], get_parent().get_node("Level").grid)
				
				# Check if we are going to the same tile
				if get_parent().get_node("Level").grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE] == currentUnit.UnitMovementStats.currentTile:
					currentUnit.UnitMovementStats.movement_queue.push_front(get_parent().get_node("Level").grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE])
				
				# Remove the unit's occupied status on the grid
				currentUnit.UnitMovementStats.currentTile.occupyingUnit = null
				
				# Play Accept
				$"AcceptSound".play()
				
				# Start moving the unit
				get_parent().get_node("Battle_Systems/Unit_Movement_System").is_moving = true
				
			else:
				$"InvalidSound".play()

# Cancel Button
func cancel_Button() -> void:
	match cursor_state:
		SELECT_MOVE_TILE:
			# Clear all highlighted tiles
			get_parent().movement_calculator.turn_off_all_tiles(currentUnit, get_parent().get_node("Level").grid)
			
			# Set Cursor back to Move status and clear current unit if needed
			cursor_state = MOVE
			updateCursorData()
			
			# Play Cancel sound
			$"BackSound".play()
			
			# Turn on the UI if not on
			emit_signal("turn_on_ui")

func set_animation_status(State: bool):
	if State:
		get_node("AnimatedCursor").visible = true
		get_node("StaticCursor").visible = false
	if !State:
		get_node("AnimatedCursor").visible = false
		get_node("StaticCursor").visible = true

func debug() -> void:
	print(get_parent().get_node("Level").grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].toString())
	print("Cursor is at: ", self.position)