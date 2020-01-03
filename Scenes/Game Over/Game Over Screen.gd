extends Control

var intro_screen = preload("res://Scenes/Intro Screen/Intro Screen.tscn")
var burn_shader = preload("res://assets/Shaders/Burn Shader Effect Shorter.tres")

var is_active = false

func _ready():
	# Stop current music
	BattlefieldInfo.music_player.get_node("AllyLevel").stop()
	
	# Start music
	$"Game Over Music".volume_db = 0
	$"Game Over Music".play(0)
	
	# Start Animation
	$"AnimationPlayer".play("Start")
	yield($AnimationPlayer, "animation_finished")
	is_active = true

func _input(event):
	if !is_active:
		return
	
	if event is InputEventKey and event.is_pressed():
		if $"AnimationPlayer".is_playing():
			$"Game Over Text".visible = false
		
		# Burn scene up
		$"Game Over Screen Image".material.set_shader_param("duration", 4.0)
		$"Game Over Screen Image".material.set_shader_param("start_time", OS.get_ticks_msec() / 1000.0)
		set_process_input(false)
		
		# Scene transition -> Finish burn effect
		$"AnimationPlayer".play("Text Fade")
		yield(get_tree().create_timer(4.2), "timeout")
		
		# Fade music
		$"AnimationPlayer".play("volume fade off")
		SceneTransition.connect("scene_changed", self, "clean_up")
		SceneTransition.change_scene(intro_screen, 0.1)
		

func clean_up():
	$"Game Over Music".stop()
	SceneTransition.disconnect("scene_changed", self, "clean_up")
	is_active = false
	queue_free()