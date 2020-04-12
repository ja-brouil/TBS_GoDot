extends KinematicBody2D

var talk_name = "Colm"

var move_dir = Vector2(0,0)
var prev_dir = Vector2(0,0)
var sprite_dir = "Idle"

var speed = 100

# Movement Vectors
var start_position = Vector2(100, 100)
var end_position = Vector2(100, 215)

var  dialogue = ["Colm@assets/units/thief/colm portrait.png@Oi, sorry your highness!",
	"Colm@assets/units/thief/colm portrait.png@I was training my endurance. I need to keep my top speed and stamina intact as a thief!",
	"Eirika@assets/units/eirika/eirika mugshot.png@I'm sorry Colm! I didn't mean to bump into you!",
	"Colm@assets/units/thief/colm portrait.png@Oh don't worry! I should be paying attention in front of me!"
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	$Animation.play("Idle")
	
	position = start_position
	
	move_dir = Vector2(0,1)

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

func _physics_process(delta):
	move_and_slide(move_dir.normalized() * speed)
	
	if position.y <= start_position.y:
		move_dir = Vector2(0, 1)
	elif position.y >= end_position.y:
		move_dir = Vector2(0, -1)
	
	set_sprite_direction()
	animation_switch()

func start_dialogue():
	BattlefieldInfo.message_system.start(dialogue)


func _on_Area2D_body_entered(body):
	if body.name == "Eirika Walk":
		prev_dir = move_dir
		move_dir = Vector2(0,0)

func _on_Area2D_body_exited(body):
	if body.name == "Eirika Walk":
		move_dir = prev_dir
	
