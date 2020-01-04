extends CanvasLayer

class_name Messaging_System
# This is for in game cinematics ONLY Use the other one for portraits


# Final position for the arrow
const ARROW_FINAL_POSITION = Vector2(70,19)

# Top/Bottom position
const BOTTOM = Vector2(122,127)
const TOP = Vector2(122,28)

# Max letters per dialogue | Use Calculator function to get the length of a text
const MAX_LETTERS = 147

# States for text
enum {scrolling, choice, input, next, wait}
var current_state = wait

# Place all text in here
var text_queue = []

# We are done processing text
signal no_more_text

func _ready():
	BattlefieldInfo.message_system = self
	# test():

func start(text_queue):
	self.text_queue = text_queue
	
	# Grab first one and scroll and set to input
	$"Dialogue Box Texture/Dialogue Text".percent_visible = 0
	$"Dialogue Box Texture/Dialogue Text".text = text_queue.pop_front()
	$"Dialogue Box Texture/Dialogue Text/Dialogue Scroll".play("Scroll")
	$"Dialogue Box Texture/Anim".play("Up and Down")
	
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
					$"Dialogue Box Texture/Arrow Texture".position = ARROW_FINAL_POSITION
				
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
					$"Dialogue Box Texture/Dialogue Text".percent_visible = 0
					$"Dialogue Box Texture/Dialogue Text".text = text_queue.pop_front()
					$"Dialogue Box Texture/Dialogue Text/Dialogue Scroll".play("Scroll")
					
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

### Test ####
func test():
	# Test
	var test_queue = [ "Eirika:\nThis is a test of what this will look like. Remember that this will automatically wrap as needed. The max amount of characters is this.",  
	"Eirika:\nThis is a test of what this will look like. Remember that this will automatically wrap as needed. The max amount of characters is this.",  \
	"Eirika:\nThis is a test of what this will look like. Remember that this will automatically wrap as needed. The max amount of characters is this.",  \
	"Eirika:\nThis is a test of what this will look like. Remember that this will automatically wrap as needed. The max amount of characters is this."]
	
	start(test_queue)