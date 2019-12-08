extends "res://Scenes/Events/Event Base.gd"

# Camera Positions
var first_camera_move = Vector2(48,0)
var second_camera_move = Vector2(0,190)
export var calc = 0

# Text for the first cutscene
var first_cutscene_text = [
	"???\n\nI have finally found you... Eirika.",
	"???\n\nToday, the Ellyisan Kingdom will finally come to an end!",
	"???\n\nCome forth my soldiers. Leave none alive!"
]

enum {first_cam, first_convo, move_enemy_units, waiting_for_camera, done}
var current_state = first_cam

func _ready():
	get_parent().get_node("Message System").connect("no_more_text", self, "move_enemies")
	$Initial.start(0)

func _process(delta):
	pass
#	match current_state:
#		first_cam:
#			if get_parent().get_node("GameCamera").position == second_camera_move:
#

# Move Camera
func move_first_camera():
	get_parent().get_node("GameCamera").position = second_camera_move
	get_parent().get_node("GameCamera").smoothing_speed = 2.0
	$Move_Cam.start(0)

func _on_Initial_timeout():
	move_first_camera()

# Move Enemies
func move_enemies():
	current_state = move_enemy_units
	get_parent().get_node("GameCamera/Turn Transition").start_level()
	get_parent().get_node("GameCamera").position = first_camera_move
	get_parent().get_node("GameCamera").smoothing_speed = 8.0

func _on_Move_Cam_timeout():
	get_parent().get_node("Message System").start(first_cutscene_text)
