# Controls the overhead display when on the battle field
extends CanvasLayer

# Battlefield access for caching purposes
var battlefield

# Positioning
enum {TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT}
var cursor_quadrant
var previous_quadrant

func _ready():
	# Battlefield access
	battlefield = get_parent()
	
	# Connect the cursor movement signal and turning off
	battlefield.get_node("Cursor").connect("cursorMoved", self, "update_battlefield_ui")
	battlefield.get_node("Cursor").connect("turn_off_ui", self, "turn_off_battlefield_ui")
	battlefield.get_node("Cursor").connect("turn_on_ui", self, "turn_on_battlefield_ui")
	
	# Connect to unit movement system
	battlefield.get_node("Battle_Systems/Unit_Movement_System").connect("unit_finished_moving", self, "turn_on_battlefield_ui")
	
	# Initial Quandrant and previous
	cursor_quadrant = TOP_LEFT
	previous_quadrant = TOP_LEFT

func update_battlefield_ui(cursor_direction, cursor_position):
	# Get cursor location and set it to the location quandrant so that we can move all the other boxes accordingly
	get_cursor_quandrant(cursor_position)
	
	# Move all the boxes to the correct spots
	
	# Update Unit Box
	update_unit_box()
	
	# Update Terrain info tile
	update_terrain_box(cursor_position)
	
	# print("Cursor moved, updating UI ", cursor_position)

# Update Unit info box
func update_unit_box():
	# Check if there is a unit and display information
	if battlefield.get_Current_Unit_Selected() != null:
		print(battlefield.get_Current_Unit_Selected()) # Set appropriate unit stats here
#		$"Battlefield HUD/Unit Info/FadeAnimU".play("Fade") # play the animation for the ui
		$"Battlefield HUD/Unit Info".visible = true
	else:
		$"Battlefield HUD/Unit Info".visible = false
#		if !$"Battlefield HUD/Unit Info/FadeAnimU".is_playing() && $"Battlefield HUD/Unit Info".modulate.a != 0:
#			$"Battlefield HUD/Unit Info/FadeAnimU".play("FadeOut")
#		else:
		

# Update Terrain
func update_terrain_box(cursor_position):
	# Get the cell where the cursor currently is
	var cursor_cell = battlefield.grid[cursor_position.x / Cell.CELL_SIZE][cursor_position.y / Cell.CELL_SIZE]
	
	# Set Tile Name
	$"Battlefield HUD/Terrain Info/T Name".text = cursor_cell.tileName
	
	# Set Stats
	$"Battlefield HUD/Terrain Info/Avd/Avd_Value".text = str(cursor_cell.avoidanceBonus)
	$"Battlefield HUD/Terrain Info/Def/Def_Value".text = str(cursor_cell.defenseBonus)

# Determine which quandrant of the screen the cursor is in
func get_cursor_quandrant(cursor_position):
	# Set Previous quadrant
	previous_quadrant = cursor_quadrant
	
	# Top or Bottom Check
	# We are on top
	var cam_x = get_parent().get_node("GameCamera/MainCamera").position.x
	var cam_y = get_parent().get_node("GameCamera/MainCamera").position.y
	print(cursor_position.x - cam_x, " " , cursor_position.y - cam_y)
	if cursor_position.x - cam_x  < (MainCamera.CAMERA_WIDTH / 2):
		# Left or Right Check
		if cursor_position.y - cam_y < (MainCamera.CAMERA_HEIGTH / 2):
			cursor_quadrant = TOP_LEFT
		else:
			cursor_quadrant = BOTTOM_LEFT
	else:
		# We are on the bottom and on the left
		if cursor_position.y - cam_y < (MainCamera.CAMERA_HEIGTH / 2):
			cursor_quadrant = TOP_RIGHT
		else:
			cursor_quadrant = BOTTOM_RIGHT
			
	# Adjust the boxes accordingly
#	if previous_quadrant != cursor_quadrant:
	move_gui_boxes()

# Moves all the boxes to the correct spot -> Fix box detection
func move_gui_boxes():
	match cursor_quadrant:
		TOP_LEFT:
			# Unit Info Box
#			if $"Battlefield HUD/Unit Info".visible && battlefield.get_Current_Unit_Selected() != null:
#				$"Battlefield HUD/Unit Info/FadeAnimU".play("Fade")
			$"Battlefield HUD/Unit Info".rect_position.x = 0 
			$"Battlefield HUD/Unit Info".rect_position.y = 115
			
			# Terrain Box
#			$"Battlefield HUD/Terrain Info/FadeAnimT".play("Fade")
			$"Battlefield HUD/Terrain Info".rect_position.x = 190
			$"Battlefield HUD/Terrain Info".rect_position.y = 120

			# Victory Box
#			$"Battlefield HUD/Victory Info/FadeAnimV".play("Fade")
			$"Battlefield HUD/Victory Info".rect_position.x = 190
			$"Battlefield HUD/Victory Info".rect_position.y = 5

		BOTTOM_LEFT:
			# Unit Info Box
#			if $"Battlefield HUD/Unit Info".visible && battlefield.get_Current_Unit_Selected() != null:
#				$"Battlefield HUD/Unit Info/FadeAnimU".play("Fade")
			$"Battlefield HUD/Unit Info".rect_position.x = 0 
			$"Battlefield HUD/Unit Info".rect_position.y = 0

			# Terrain Box
			$"Battlefield HUD/Terrain Info".rect_position.x = 190
			$"Battlefield HUD/Terrain Info".rect_position.y = 120

			# Victory Box
			$"Battlefield HUD/Victory Info".rect_position.x = 190
			$"Battlefield HUD/Victory Info".rect_position.y = 5


		TOP_RIGHT:
			# Unit Info Box
			$"Battlefield HUD/Unit Info".rect_position.x = 0 
			$"Battlefield HUD/Unit Info".rect_position.y = 115

			# Terrain Box
			$"Battlefield HUD/Terrain Info".rect_position.x = 190
			$"Battlefield HUD/Terrain Info".rect_position.y = 120

			# Victory Box
#			$"Battlefield HUD/Victory Info/FadeAnimV".play("Fade")
			$"Battlefield HUD/Victory Info".rect_position.x = 5
			$"Battlefield HUD/Victory Info".rect_position.y = 5

		BOTTOM_RIGHT:
			# Unit Info Box
			$"Battlefield HUD/Unit Info".rect_position.x = 0 
			$"Battlefield HUD/Unit Info".rect_position.y = 115

			# Terrain Box
#			$"Battlefield HUD/Terrain Info/FadeAnimT".play("Fade")
			$"Battlefield HUD/Terrain Info".rect_position.x = 190
			$"Battlefield HUD/Terrain Info".rect_position.y = 5

			# Victory Box
			$"Battlefield HUD/Victory Info".rect_position.x = 5
			$"Battlefield HUD/Victory Info".rect_position.y = 5

# Turn off all UI elements of the battlefield
func turn_off_battlefield_ui():
	$"Battlefield HUD".visible = false

# Turn on all UI elements of the battlefield
func turn_on_battlefield_ui():
	$"Battlefield HUD".visible = true