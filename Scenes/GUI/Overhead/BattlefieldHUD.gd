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
	
	# Connect cursor to the Area
	get_parent().get_node("GameCamera/Areas/BottomLeft").connect("body_entered", self, "bottom_left")
	get_parent().get_node("GameCamera/Areas/BottomRight").connect("body_entered", self, "bottom_right")
	get_parent().get_node("GameCamera/Areas/TopLeft").connect("body_entered", self, "top_left")
	get_parent().get_node("GameCamera/Areas/TopRight").connect("body_entered", self, "top_right")
	
	# Connect to unit movement system
	BattlefieldInfo.unit_movement_system.connect("unit_finished_moving", self, "turn_on_battlefield_ui")
	
	# Initial Quandrant and previous
	cursor_quadrant = TOP_LEFT
	previous_quadrant = TOP_LEFT
	
	# Box Fade Connector
	

func update_battlefield_ui(cursor_direction, cursor_position):
	# Update Unit Box
	update_unit_box()
	
	# Move Boxes
	move_gui_boxes()
	
	# Update Terrain info tile
	update_terrain_box(cursor_position)

# Update Unit info box
func update_unit_box():
	# Check if there is a unit and display information
	if BattlefieldInfo.current_Unit_Selected != null:
		print(BattlefieldInfo.current_Unit_Selected) # Set appropriate unit stats here
		$"Battlefield HUD/Unit Info/FadeAnimU".play("Fade") # play the animation for the ui
		$"Battlefield HUD/Unit Info".visible = true
	else:
		$"Battlefield HUD/Unit Info/FadeAnimU".play("FadeOut")

func _on_unit_box_fade():
	$"Battlefield HUD/Unit Info".visible = false

# Update Terrain
func update_terrain_box(cursor_position):
	# Get the cell where the cursor currently is
	var cursor_cell = BattlefieldInfo.grid[cursor_position.x / Cell.CELL_SIZE][cursor_position.y / Cell.CELL_SIZE]
	
	# Set Tile Name
	$"Battlefield HUD/Terrain Info/T Name".text = cursor_cell.tileName
	
	# Set Stats
	$"Battlefield HUD/Terrain Info/Avd/Avd_Value".text = str(cursor_cell.avoidanceBonus)
	$"Battlefield HUD/Terrain Info/Def/Def_Value".text = str(cursor_cell.defenseBonus)

# Determine which quandrant of the screen the cursor is in
func bottom_left(body) -> void:
	cursor_quadrant = BOTTOM_LEFT

func bottom_right(body) -> void:
	cursor_quadrant = BOTTOM_RIGHT

func top_left(body) -> void:
	cursor_quadrant = TOP_LEFT

func top_right(body) -> void:
	cursor_quadrant = TOP_RIGHT

# Moves all the boxes to the correct spot -> Fix box detection
func move_gui_boxes():
	match cursor_quadrant:
		TOP_LEFT:
			# Unit Info Box
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