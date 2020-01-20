extends CanvasLayer

func start(chapter_number, chapter_name, next_chapter_path, delay):
	# Change Text
	$"Container/Chapter Number".text = str("Chapter ", chapter_number)
	$"Container/Chapter Name".text = chapter_name
	
	# Play Animation
	$Container/Anim.play("Fade ")

	yield($Container/Anim,"animation_finished")
	
	# Play Sound
	#$"Container/Chapter Start".play(0)
	
	# Wait 2 seconds then move on
	yield(get_tree().create_timer(2.0), "timeout")
	
	# Remove World Map
	get_node("/root/WorldMapScreen").visible = false
	
	# Fade Back
	$Container/Anim.play_backwards("Fade ")
	yield($Container/Anim,"animation_finished")
	
	# Set Camera
	BattlefieldInfo.main_game_camera.current = true
	
	# Change Scene
	var unzip_scene = load(next_chapter_path)
	var new_level = unzip_scene.instance()
	
	get_node("/root/Level").add_child(new_level)
	queue_free()

func set_fog_color(color):
	$Container/Fog.modulate = color
