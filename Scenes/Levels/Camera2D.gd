extends Camera2D

# Declare member variables here. Examples:
var slowTime = 0
var tileSize = 16

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	slowTime += delta
	moveCamera(slowTime)	

func moveCamera(slowTime):
	if slowTime <= 0.05:
		return
		
	# Adjust camera based on movement
	if Input.is_action_pressed("ui_right"):
		self.position.x += tileSize
	elif Input.is_action_pressed("ui_left"):
		self.position.x -= tileSize
	elif Input.is_action_pressed("ui_up"):
		self.position.y -= tileSize
	elif Input.is_action_pressed("ui_down"):
		self.position.y += tileSize
		
	# Reset time
	self.slowTime = 0