extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Play Song
func play_song(song_name, starting_position) -> void:
	$song_name.play(starting_position)

# Stop song
func stop_song(song_name) -> void:
	$song_name.stop()