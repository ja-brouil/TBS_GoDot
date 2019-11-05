extends Node
class_name Music_Player
# TEST FOR LOOP
# ALLY LOOP END: 9506236

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Play Song
func play_song(song_name, starting_position) -> void:
	get_node(song_name).play(starting_position)

# Stop song
func stop_song(song_name) -> void:
	get_node(song_name).stop()