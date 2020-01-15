extends Sprite

func _ready():
	# Test for sprite
	texture = get_parent().get_node("Viewport").get_texture()