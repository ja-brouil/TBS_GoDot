extends KinematicBody2D

class_name Eirka_Walk

# Sprite direction
export(String) var sprite_dir = "left"
export(Vector2) var move_dir = Vector2(0,0)

# Movement Speed
export(int) var SPEED = 100

# Current mode
enum STATUS {CHAT, UI, WALK}
var current_status = STATUS.WALK

# Current chat
var current_chat_unit = null

func _ready():
	$Animation.play("Idle")
	
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "_back_to_walk")

# Set Sprite Direction
func set_sprite_direction():
	match move_dir:
		Vector2(-1,0):
			sprite_dir = "Left"
		Vector2(1,0):
			sprite_dir = "Right"
		Vector2(0,-1):
			sprite_dir = "Up"
		Vector2(0,1):
			sprite_dir = "Down"
		Vector2(0,0):
			sprite_dir = "Idle"

func animation_switch():
	if $Animation.current_animation != str(sprite_dir, " no sound"):
		if sprite_dir == "Idle":
			$Animation.current_animation = sprite_dir
		else:
			$Animation.current_animation = str(sprite_dir, " no sound")

func _input(event):
	# Reset
	move_dir = Vector2(0,0)
	SPEED = 100
	
	# Debug
	if Input.is_action_just_pressed("debug"):
		print("Position of Eirika: ", position)
	
	match current_status:
		STATUS.WALK:
			# Movement
			var LEFT = Input.is_action_pressed("ui_left")
			var RIGHT = Input.is_action_pressed("ui_right")
			var UP = Input.is_action_pressed("ui_up")
			var DOWN = Input.is_action_pressed("ui_down")
			
			# Move faster if D is pressed
			if Input.is_action_pressed("L button"):
				SPEED *= 2
			
			# Prevent multiple key pressdowns from having priority over others
			move_dir.x = -int(LEFT) + int(RIGHT)
			move_dir.y = -int(UP) + int(DOWN)
			
			# Accept button
			if Input.is_action_just_pressed("ui_accept"):
				if current_chat_unit != null:
					current_chat_unit.start_dialogue()
					current_status = STATUS.CHAT
					# Wait for 0.2 seconds
					yield(get_tree().create_timer(0.2), "timeout")

# Physics Movements
func _physics_process(delta):
	move_and_slide(move_dir.normalized() * SPEED)
	set_sprite_direction()
	animation_switch()
	clamp_eirika()

# Clamp position
func clamp_eirika():
	position.x = clamp(position.x, 0, Test_Walk_Map.MAP_LIMIT.x)
	position.y = clamp(position.y, 0, Test_Walk_Map.MAP_LIMIT.y)


func _on_Area2D_body_entered(body):
	if body.has_method("start_dialogue"):
		current_chat_unit = body

func _on_Area2D_body_exited(body):
	current_chat_unit = null

func _back_to_walk():
	current_status = STATUS.WALK
