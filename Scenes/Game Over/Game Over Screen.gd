extends Control

var intro_screen = "res://Scenes/Intro Screen/Intro Screen.tscn"

var is_active = false

func _ready():
	# Stop current music
	BattlefieldInfo.music_player.get_node("AllyLevel").stop()

	# Start music
	$"Game Over Music".volume_db = 0
	$"Game Over Music".play(0)

	# Param time
	$"Game Over Screen Image".material.set_shader_param("start_time", 9999999.0)

	# Start Animation
	$"AnimationPlayer".play("Start")
	yield($AnimationPlayer, "animation_finished")
	SceneTransition.connect("scene_changed", self, "clean_up")
	is_active = true
	
	# Remove current camera
	$"/root/Level/GameCamera".current = false
	
	# Remove Extra
	BattlefieldInfo.level_container.queue_free()

func _input(event):
	if !is_active:
		return
	
	if event is InputEventKey and event.is_pressed():
		is_active = false
		if $"AnimationPlayer".is_playing():
			$"Game Over Text".visible = false
		
		# Burn scene up
		$"Game Over Screen Image".material.set_shader_param("duration", 4.0)
		$"Game Over Screen Image".material.set_shader_param("start_time", OS.get_ticks_msec() / 1000.0)
		
		# Scene transition -> Finish burn effect
		$"AnimationPlayer".play("Text Fade")
		yield(get_tree().create_timer(4.2), "timeout")
		
		# Fade music
		$"AnimationPlayer".play("volume fade off")
		$"Game Over Screen Image".modulate = Color(1,1,1,0)
		SceneTransition.change_scene(intro_screen, 0.1)

func clean_up():
	$"Game Over Music".stop()
	SceneTransition.disconnect("scene_changed", self, "clean_up")
	queue_free()
