extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("this node is now ready to be used!")
	get_node("Anim").play("red to green to blue")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
