
extends Node

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		print("pressed from Node")
