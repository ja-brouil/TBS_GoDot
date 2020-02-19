extends CanvasLayer

class_name Messaging_System
# This is for in game cinematics ONLY Use the other one for portraits

# Top/Bottom position
const BOTTOM = Vector2(122,127)
# const TOP = Vector2(122,28)
const TOP = Vector2(122,127)

# Max letters per dialogue | Use Calculator function to get the length of a text
const MAX_LETTERS = 147

# States for text
enum {scrolling, choice, input, next, wait}
var current_state = wait

# Place all text in here
var text_queue = []

# We are done processing text
signal no_more_text

# Node access
onready var portrait = $"Dialogue Box Texture/Portrait"
onready var char_name = $"Dialogue Box Texture/Character Name"

func _ready():
	BattlefieldInfo.message_system = self

func start(text_queue):
	self.text_queue = parse(text_queue)
	
	# Grab first one and scroll and set to input
	next_line(self.text_queue.pop_front())
	
	# Turn on
	turn_on()
	
	# Set State
	current_state = input

# Process Skip
func _input(event):
	# Skip to end of text is A is pressed
	match current_state:
		input:
			if Input.is_action_just_pressed("ui_accept"):
				# Stop moving the arrow and set the new position
				if text_queue.size() == 0:
					$"Dialogue Box Texture/Anim".stop(true)
				
				# Stop the scroll and set it to max visiblity
				if $"Dialogue Box Texture/Dialogue Text/Dialogue Scroll".is_playing():
					$"Dialogue Box Texture/Dialogue Text/Dialogue Scroll".stop(true)
					$"Dialogue Box Texture/Dialogue Text".percent_visible = 1
				
				# Set to next
				current_state = next
		next:
			# Process next line of text. If there is none, then we emit a signal and head out
			if Input.is_action_just_pressed("ui_accept"):
				# Do we have any more text?
				if text_queue.size() == 0:
					turn_off()
					current_state = wait
					emit_signal("no_more_text")
					
				else:
					# Grab first one and scroll and set to input
					next_line(text_queue.pop_front())
					
					# Back to input
					current_state = input
		choice:
			pass

func _on_Dialogue_Scroll_animation_finished(anim_name):
	current_state = next

func turn_on():
	$"Dialogue Box Texture".visible = true

func turn_off():
	$"Dialogue Box Texture".visible = false

func set_position(new_position):
	$"Dialogue Box Texture".position = new_position

# Parse the text and store into an array
func parse(text_line):
	var parsed_array = []
	for text_string in text_line:
		var array_line = text_string.split("@")
		parsed_array.append(array_line)
	return parsed_array

func next_line(text_line):
	# Only 1 line = narrator
	if text_line.size() == 1:
		# Set Text
		$"Dialogue Box Texture/Dialogue Text".bbcode_text = text_line[0]
		
		# Disable the portrait
		portrait.visible = false
		
		# Set name to some default
		char_name.text = " "
	else:
		# Set Text
		$"Dialogue Box Texture/Dialogue Text".bbcode_text = text_line[2]
		
		# Set portrait
		var n_portrait = load(str("res://",text_line[1]))
		portrait.texture = n_portrait
		portrait.visible = true
		
		# Set name
		char_name.text = text_line[0]
	
	# Always  happens
	$"Dialogue Box Texture/Dialogue Text".percent_visible = 0
	$"Dialogue Box Texture/Dialogue Text/Dialogue Scroll".play("Scroll")
	$"Dialogue Box Texture/Anim".play("Up and Down")

### Test ####
func test():
	# Test
	var test_queue = [ "Eirika @assets/units/eirika/eirika mugshot.png@This is a test of what this will look like. Remember that this will automatically wrap as needed. The max amount of characters is this.",  
	"Anna @assets/UI/shop/Anna portrait.png@Oh hello there! I'm [b]Anna[/b]!",
	"Anna @assets/UI/shop/Anna portrait.png@Let's suppose you have the same portrait twice in a row. [wave amp=15 freq=20]Does this leak memory?[/wave]",
	"Okay well, now you have no portrait and no name. Did this crash the game?",
	"Seth @assets/units/cavalier/seth mugshot.png@Hello, we now have a portrait again and a new name!",
	"Seth @assets/units/cavalier/seth mugshot.png@Isn't James the best programmer in the world?"
	]
	
	start(test_queue)
