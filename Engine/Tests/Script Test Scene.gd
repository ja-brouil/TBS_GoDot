extends Node2D

func _ready():
	$anim.play("test")
	
	

func _on_anim_animation_finished(anim_name):
	print(anim_name)
	print("es" in anim_name)
