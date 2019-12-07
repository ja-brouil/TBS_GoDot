extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input(event):
	if Input.is_action_just_pressed("debug"):
		$"Dialogue Box Texture/Dialogue/Dialogue Scroll".play("Scroll")

