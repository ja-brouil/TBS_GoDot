extends Node2D

var ally_texture;
var enemy_texture;

func _ready():
	BattlefieldInfo.turn_manager.connect("play_transition", self, "start_transition")
	
	ally_texture = $"Player Turn".texture
	enemy_texture = $"Enemy Phase".texture

func start_transition(type):
	if type == "Enemy":
		$"Player Turn".texture = enemy_texture
		$Animation.current_animation = "Move_Off"
	else:
		$"Player Turn".texture = enemy_texture
		$Animation.current_animation = "Move_Off"

func _process(delta):
	if Input.is_action_just_pressed("debug"):
		$Animation.current_animation = "Move_Off"