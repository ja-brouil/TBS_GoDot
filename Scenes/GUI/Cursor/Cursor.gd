extends Node2D
class_name Cursor

# Signal for camera and other UI elements to update
signal cursorMoved

# Turn off UI elements when the unit starts moving
signal turn_off_ui
signal turn_on_ui

# Unit cycle
var all_ally_units = [] 

# Which mode is the cursor in
enum {MOVE, SELECT_MOVE_TILE, WAIT, PREP}
var cursor_state

# Swap Variables
var ally_1
var ally_2

func _ready():
	# Start cursor animation
	$"AnimatedCursor/AnimationPlayer".play("Moving")
	
	# Intial enum
	cursor_state = WAIT
	
	# Connect to Movement
	get_parent().get_node("Action Selector Screen").connect("selected_wait", self, "enable_standard")
	
	# Connec to turn transition
	BattlefieldInfo.turn_manager.connect("play_transition", self, "disable_standard")
	
	# Cursor to battlefield
	BattlefieldInfo.cursor = self
	
	# Clear the array
	all_ally_units.clear()
	
func _input(event):
	# Do not process if game is over or won
	if BattlefieldInfo.victory || BattlefieldInfo.game_over || BattlefieldInfo.stop_end_of_turn:
		return
	
	# Do not process if cursor is in wait mode
	if cursor_state == WAIT:
		return
	
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
		updateCursorData()
		acceptButton()
	elif Input.is_action_just_pressed("ui_cancel"):
		cancel_Button()
	elif Input.is_action_just_pressed("L button"):
		updateCursorData()
		l_button()
	elif Input.is_action_just_pressed("R button"):
		updateCursorData()
		r_button()
	
	if Input.is_action_just_pressed("debug"):
		debug()

# Update cursor
func updateCursorData() -> void:
	# Clamp the cursor
	self.position.x = clamp(self.position.x, 0, (BattlefieldInfo.map_width * Cell.CELL_SIZE) - Cell.CELL_SIZE)
	self.position.y = clamp(self.position.y, 0, (BattlefieldInfo.map_height * Cell.CELL_SIZE) - Cell.CELL_SIZE)
	
	# Move Mode
	match cursor_state:
		MOVE:
			# Set Animation status of unit if not null -> This is if you go from one cell to another and both are adj and occupied
			if BattlefieldInfo.current_Unit_Selected != null:
					BattlefieldInfo.current_Unit_Selected.get_node("Animation").current_animation = "Idle"
					set_animation_status(true)
					
					# Remove Global Unit
					BattlefieldInfo.current_Unit_Selected = null
			
			# check if the cell if occupied
			if BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit != null:
				BattlefieldInfo.current_Unit_Selected = BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit
				
				# Set Global Variable
				BattlefieldInfo.current_Unit_Selected = BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit
				
				# Show possible moves
				# Highlight ranges
				BattlefieldInfo.movement_calculator.calculatePossibleMoves(BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit, BattlefieldInfo.grid)
				
				# Check if this unit is an ally
				if BattlefieldInfo.current_Unit_Selected.UnitMovementStats.is_ally && BattlefieldInfo.current_Unit_Selected.UnitActionStatus.get_current_action() != Unit_Action_Status.DONE:
					BattlefieldInfo.current_Unit_Selected.get_node("Animation").current_animation = "Selected"
					# Stop Cursor animation
					set_animation_status(false)
				
			else:
				# Do we have a unit selected right now?
				if BattlefieldInfo.current_Unit_Selected != null:
					BattlefieldInfo.current_Unit_Selected.get_node("Animation").current_animation = "Idle"
					
					# Turn off the cells
					BattlefieldInfo.movement_calculator.turn_off_all_tiles(BattlefieldInfo.current_Unit_Selected, BattlefieldInfo.grid)
					
					# Remove Global Unit
					BattlefieldInfo.current_Unit_Selected = null
					
					# Start animation of the cursor again
					set_animation_status(true)
		PREP:
			# Set Animation status of unit if not null -> This is if you go from one cell to another and both are adj and occupied
			if BattlefieldInfo.current_Unit_Selected != null:
					set_animation_status(true)
					# Remove Global Unit
					BattlefieldInfo.current_Unit_Selected = null
			
			# check if the cell if occupied
			if BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit != null:
				# Set Global Variable
				BattlefieldInfo.current_Unit_Selected = BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit
				
				# Check if this unit is an ally
				if BattlefieldInfo.current_Unit_Selected.UnitMovementStats.is_ally && BattlefieldInfo.current_Unit_Selected.UnitActionStatus.get_current_action() != Unit_Action_Status.DONE:
					# Stop Cursor animation
					set_animation_status(false)
				
			else:
				# Do we have a unit selected right now?
				if BattlefieldInfo.current_Unit_Selected != null:
					# Remove Global Unit
					BattlefieldInfo.current_Unit_Selected = null
					
					# Start animation of the cursor again
					set_animation_status(true)

# Accept Button
func acceptButton() -> void:
	match cursor_state:
		MOVE:
		# Open end turn window # Send a signal out here -> Or if you pressed a unit that is done
			if BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit == null || BattlefieldInfo.current_Unit_Selected.UnitActionStatus.get_current_action() == Unit_Action_Status.DONE:
				# Play accept sound
				$"AcceptSound".play()
				
				# Activate the end turn window
				get_parent().get_node("End Turn").start()
				
				# Turn this off
				enable(false, WAIT)
				
				# Turn UI Off
				emit_signal("turn_off_ui")
				return
			
			# Set current unit to the global unit selector
			BattlefieldInfo.current_Unit_Selected = BattlefieldInfo.current_Unit_Selected
			
			# Set Selected Animation to current unit
			if BattlefieldInfo.current_Unit_Selected.UnitMovementStats.is_ally:
				BattlefieldInfo.current_Unit_Selected.get_node("Animation").current_animation = "Highlighted"
			
			# Highlight ranges
			BattlefieldInfo.movement_calculator.calculatePossibleMoves(BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit, BattlefieldInfo.grid)
			
			# Set Cursor to the move status
			cursor_state = SELECT_MOVE_TILE
			
			# Set previous camera location so we can move back to it
			BattlefieldInfo.previous_camera_position = get_parent().get_node("GameCamera").position
			
			# Set animation back to true
			set_animation_status(true)
			
			# Sound
			$"SelectUnitSound".play()
			
			# Turn off UI
			emit_signal("turn_off_ui")
			
		SELECT_MOVE_TILE:
			# Validate that this is an ally
			if !BattlefieldInfo.current_Unit_Selected.UnitMovementStats.is_ally:
				cancel_Button()
				return
			
			# Validate if tile is in the list
			if BattlefieldInfo.movement_calculator.check_if_move_is_valid(BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE], BattlefieldInfo.current_Unit_Selected):
				# Set the old position so that we can go back if needed
				BattlefieldInfo.previous_position = BattlefieldInfo.current_Unit_Selected.UnitMovementStats.currentTile.position
				
				# Get the path to the tile
				BattlefieldInfo.movement_calculator.get_path_to_destination(BattlefieldInfo.current_Unit_Selected, BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE], BattlefieldInfo.grid)
				
				# Check if we are going to the same tile
				if BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE] == BattlefieldInfo.current_Unit_Selected.UnitMovementStats.currentTile:
					BattlefieldInfo.current_Unit_Selected.UnitMovementStats.movement_queue.push_front(BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE])
				
				# Remove the unit's occupied status on the grid
				BattlefieldInfo.current_Unit_Selected.UnitMovementStats.currentTile.occupyingUnit = null
				
				# Play Accept
				$"AcceptSound".play()
				
				# Move Camera back to original spot first
				BattlefieldInfo.main_game_camera.position = (BattlefieldInfo.current_Unit_Selected.position + Vector2(-112, -82))
				BattlefieldInfo.main_game_camera.smoothing_speed = 2
				
				# Start moving the unit
				BattlefieldInfo.unit_movement_system.is_moving = true
				
				# Turn off Cursor
				enable(false, WAIT)
				
			else:
				$"InvalidSound".play()
		PREP:
			# Is this cell part of the swap? If no, we don't care
			if BattlefieldInfo.swap_points.has(BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE]):
				# Is the swap cell occupied?
				if BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit != null:
					# Do we have an ally in ally 1?
					if ally_1 == null:
						ally_1 = BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit
						ally_1.get_node("Animation").current_animation = "Highlighted"
						$AcceptSound.play(0)
					else:
						# Are we trying to place someone at the same cell?
						if ally_1 == BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit:
							$InvalidSound.play(0)
						else:
							# Cache
							ally_2 = BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit
							# Get old position
							var original_position_of_ally_1 = ally_1.position
							var original_position_of_ally_2 = ally_2.position
	
							# Remove Current Unit from both tiles
							ally_1.UnitMovementStats.currentTile.occupyingUnit = null
							ally_2.UnitMovementStats.currentTile.occupyingUnit = null
	
							# Move ally 1
							ally_1.UnitMovementStats.currentTile = ally_2.UnitMovementStats.currentTile
							ally_1.position = ally_2.position
							BattlefieldInfo.grid[original_position_of_ally_2.x / Cell.CELL_SIZE][original_position_of_ally_2.y / Cell.CELL_SIZE].occupyingUnit = ally_1
	
							# Move ally 2 now
							ally_2.UnitMovementStats.currentTile = BattlefieldInfo.grid[original_position_of_ally_1.x / Cell.CELL_SIZE][original_position_of_ally_1.y / Cell.CELL_SIZE]
							ally_2.position = original_position_of_ally_1
							BattlefieldInfo.grid[original_position_of_ally_1.x / Cell.CELL_SIZE][original_position_of_ally_1.y / Cell.CELL_SIZE].occupyingUnit = ally_2
	
							# Update cursor
							updateCursorData()
							emit_signal("cursorMoved", "left", self.position)
	
							# Play sound
							$AcceptSound.play(0)
	
							# Set animation
							ally_1.get_node("Animation").current_animation = "Idle"
	
							# Clear everything
							ally_1 = null
							ally_2 = null
				else:
					# Do we have someone in ally 1?
					if ally_1 != null:
						# Cache
						var new_tile = BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE]
						
						# Remove the old tile info
						ally_1.UnitMovementStats.currentTile.occupyingUnit = null
						ally_1.UnitMovementStats.currentTile = null
						
						# Set new info
						ally_1.UnitMovementStats.currentTile = new_tile
						new_tile.occupyingUnit = ally_1
						ally_1.position = new_tile.position
						
						# Play sound
						$AcceptSound.play(0)

						# Set animation
						ally_1.get_node("Animation").current_animation = "Idle"

						# Clear everything
						ally_1 = null
						ally_2 = null
# Cancel Button
func cancel_Button() -> void:
	match cursor_state:
		SELECT_MOVE_TILE:
			# Clear all highlighted tiles
			BattlefieldInfo.movement_calculator.turn_off_all_tiles(BattlefieldInfo.current_Unit_Selected, BattlefieldInfo.grid)
			
			# Set Cursor back to Move status and clear current unit if needed
			cursor_state = MOVE
			updateCursorData()
			
			# Play Cancel sound
			$"BackSound".play()
			
			# Turn on the UI if not on
			emit_signal("turn_on_ui")
		PREP:
			# Is ally 1 occupied?
			if ally_1 != null:
				$"BackSound".play()
				ally_1.get_node("Animation").current_animation = "Idle"
				ally_1 = null
			else:
				# Go back to prep screen
				$"BackSound".play()
				cursor_state = WAIT
				
				# Turn on prep screen
				BattlefieldInfo.preparation_screen.turn_on()
				
				# Turn off blue squares and save the current info on these units
				for blueTile in BattlefieldInfo.swap_points:
					blueTile.get_node("MovementRangeRect").turnOff("Blue")
					
					BattlefieldInfo.preparation_screen.previous_units_selection.clear()
					if blueTile.occupyingUnit != null:
						BattlefieldInfo.preparation_screen.previous_units_selection.append = blueTile.occupyingUnit

# L Button -> Go to next unit that is available
func l_button() ->  void:
	# Check if we have new units or any unit has died
	if all_ally_units.size() != BattlefieldInfo.ally_units.size():
		all_ally_units.clear()
		# We units that were added or died
		for ally_unit in BattlefieldInfo.ally_units.values():
			all_ally_units.append(ally_unit)
	for ally_unit in all_ally_units:
		if ally_unit.UnitActionStatus.get_current_action() == Unit_Action_Status.MOVE:
			# Remove ally unit
			var temp = ally_unit
			all_ally_units.erase(ally_unit)
			
			# Set position
			BattlefieldInfo.main_game_camera.position = (temp.position + Vector2(-112, -82))
			BattlefieldInfo.main_game_camera.clampCameraPosition()
			BattlefieldInfo.cursor.position = temp.position
			
			# Update UI
			updateCursorData()
			emit_signal("cursorMoved", "left", self.position)
			
			# Set to the back of the array
			all_ally_units.append(temp)
			
			# Stop loop
			break

func r_button() -> void:
	if BattlefieldInfo.current_Unit_Selected != null && (cursor_state == MOVE || cursor_state == PREP):
		if cursor_state == PREP:
			set_process_input(false)
		emit_signal("turn_off_ui")
		disable_standard("standard")
		BattlefieldInfo.unit_info_screen.turn_on()

# Set animations state
func set_animation_status(State: bool):
	if State:
		get_node("AnimatedCursor").visible = true
		get_node("StaticCursor").visible = false
	if !State:
		get_node("AnimatedCursor").visible = false
		get_node("StaticCursor").visible = true

# Enable or disable visibility
func enable(status, next_cursor_state):
	visible = status
	cursor_state = next_cursor_state
	if cursor_state == PREP:
		set_process_input(true)
	updateCursorData()

# Standard enable
func enable_standard():
	visible = true
	$Timer.start(0)
	emit_signal("turn_on_ui")

func disable_standard(transition_type):
	visible = false
	if cursor_state != PREP:
		cursor_state = WAIT
	emit_signal("turn_off_ui")

func back_to_move():
	if cursor_state == PREP:
		enable(true, PREP)
	elif BattlefieldInfo.turn_manager.turn == Turn_Manager.PLAYER_TURN:
		enable(true, MOVE)

func debug() -> void:
	print(BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].toString())
	print("Cursor is at: ", self.position)
	if BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit != null:
		print("Unit Name: ", BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit.UnitStats.name)
		print("Unit Status: ", BattlefieldInfo.grid[self.position.x / Cell.CELL_SIZE][self.position.y / Cell.CELL_SIZE].occupyingUnit.UnitActionStatus.get_current_action())

# Prevent this scene from automatically starting the event input
func _on_Timer_timeout():
	if BattlefieldInfo.turn_manager.turn != Turn_Manager.ENEMY_TURN && BattlefieldInfo.turn_manager.turn != Turn_Manager.WAIT:
		cursor_state = MOVE
