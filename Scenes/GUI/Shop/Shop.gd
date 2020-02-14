extends CanvasLayer

# Shop UI
# Inventory for the shop
const item_shop = {}

# Current index
var current_index = 0

# Scroll bar p value
var previous_scroll_value = 0

# State machine for the shop
enum SHOP_STATE {BUY, SELL}
var current_state = null

# Default starting position for the hand
const STARTING_HAND_POSITION = Vector2(42, 75)
const HAND_Y_INCREASE = Vector2(0, 12)

# Various Nodes
onready var shop_list = $"Shop UI/ShopList"
onready var hand_selector = $"Hand Selector"
onready var scroll_bar = $"Shop UI/ShopList".get_v_scroll()
onready var anim = $Anim

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set selected item to the first one in the list
	current_index = 0
	shop_list.select(current_index)
	shop_list.grab_focus()
	
	# Disable scroll bar with mouse
	shop_list.get_v_scroll().mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Signal for bar
	shop_list.get_v_scroll().connect("value_changed", self, "_adjust_hand_value")
	
	# Set Hand
	hand_selector.rect_position = STARTING_HAND_POSITION
	
	# Play Fade in
	$"Shop UI/Shop Music".play()
	$Anim.play("Fade")
	yield($Anim, "animation_finished")
	
	# Play Welcome!
	$"Shop UI/Shop Greeting".play()
	
	# Start
	start(SHOP_STATE.BUY)

func sell_item():
	# Remove item from the unit's inventory
	
	# Increase gold amount by item's worth
	pass

func buy_item():
	# Check if there is enough money
	
	# Check if unit has inventory space
	
	# Create new item
	
	# Add it to the inventory
	pass

func start(shop_state):
	# Set shop State
	current_state = shop_state
	
	# Set previous scroll value
	previous_scroll_value = 0

func exit():
	# Play Goodbye
	pass

func _input(event):
	# Get State
	match current_state:
		SHOP_STATE.BUY:
			# Accept button
			if Input.is_action_just_pressed("ui_accept"):
				shop_list.grab_focus()
				print(shop_list.get_item_text(current_index))
			
		SHOP_STATE.SELL:
			pass
	
	# Test for exit
	if Input.is_action_just_pressed("debug"):
		$"Shop UI/Shop Exit".play()
		shop_list.grab_focus()

# Whenever an item is selected
func _on_ShopList_item_selected(index):
	# Set current index
	current_index = index
	
	# Move hand
	if Input.is_action_pressed("ui_up"):
		hand_selector.rect_position -= HAND_Y_INCREASE
	
	if Input.is_action_pressed("ui_down"):
		hand_selector.rect_position += HAND_Y_INCREASE
	
	# Play cursor sound
	hand_selector.get_node("Move").play()

# Adjust hand value when the scroll changes
func _adjust_hand_value(value):
	# Did the Value go up?
	if previous_scroll_value > value:
		hand_selector.rect_position += HAND_Y_INCREASE
	else:
		hand_selector.rect_position -= HAND_Y_INCREASE
	
	# Set new previous value
	previous_scroll_value = value
