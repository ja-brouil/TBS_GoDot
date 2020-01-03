extends Node
class_name Music_Player

# Music List
const m_FODLAND_WINGS_PATH = "res://assets/music/Fodlan Winds.ogg"
const m_CHASING_DAY_BREAK_PATH = "res://assets/music/Chasing Daybreak.ogg"
const m_UNFUFILLED_PATH = "res://assets/music/Unfufilled.ogg"
const m_TEARING_THRU_HEAVEN_PATH = "res://assets/music/Tearing through Heaven.ogg"

# Play Song
func play_song(song_name, starting_position) -> void:
	get_node(song_name).play(starting_position)
	$EnemyLevel.volume_db

# Stop song
func stop_song(song_name) -> void:
	get_node(song_name).stop()