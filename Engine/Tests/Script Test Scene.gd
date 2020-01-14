extends Control

func _input(event):
	if Input.is_action_just_pressed("debug"):
		$anim.play("test")