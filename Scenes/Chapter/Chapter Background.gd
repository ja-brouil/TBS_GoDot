extends CanvasLayer

func start(chapter_number, chapter_name, next_chapter_path, delay):
	# Change Text
	$"Container/Chapter Number".text = str("Chapter ", chapter_number)
	$"Container/Chapter Name".text = chapter_name
	
	# Visible
	$Container.visible = true
	
	# Play Animation
	$Container/Anim.play("Fade ")

	yield($Container/Anim,"animation_finished")
	
	# Play Sound
	#$"Container/Chapter Start".play(0)
	
	# Wait 2 seconds then move on
	yield(get_tree().create_timer(2.0), "timeout")
	$Container/Anim.play_backwards("Fade ")
	yield($Container/Anim,"animation_finished")
	$Container.visible = false
	SceneTransition.change_scene_to(next_chapter_path, 0.1)

func set_fog_color(color):
	$Container/Fog.modulate = color
