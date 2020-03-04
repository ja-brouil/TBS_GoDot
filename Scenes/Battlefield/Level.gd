extends Node2D

# Set music
var level_music = preload("res://assets/music/Fodlan Winds.ogg")

# Set Title
var chapter_title = "Chapter 1: Victims of War"

# Level reference itself
var current_chapter

func _ready():
	BattlefieldInfo.battlefield_container = self
