extends CanvasLayer

class_name Shop_UI

# Shop UI
# Inventory for the shop
const item_shop = {}

# Current index
var current_index = 0

# Scroll bar p value
var previous_scroll_value = 0

# State machine for the shop
enum SHOP_STATE {BUY, SELL, CONFIRM_BUY, CONFIRM_SELL, SELECT_UNIT, OFF}
var current_state = null

# Default starting position for the hand
const STARTING_HAND_POSITION = Vector2(42, 75)
const HAND_Y_INCREASE = Vector2(0, 12)

# Confirm hand variables
const YES_POSITION = Vector2(76,27)
const NO_POSITION = Vector2(135,27)
const OFF_SCREEN = Vector2(-300,-300)

# Confirm buy variables
var confirm_buy_index = 0

# Confirm sell variables
var confirm_sell_index = 0

# Price
var current_price = 0

# Unit solo picker signal
signal inventory_full

# Test for walkable map
var came_from_walkable_map = false

# Various Nodes
onready var shop_list = $"Shop UI/ShopList"
onready var shop_list_price = $"Shop UI/ShopListPrice"
onready var hand_selector = $"Hand Selector"
onready var scroll_bar = $"Shop UI/ShopList".get_v_scroll()
onready var scroll_bar2 = $"Shop UI/ShopListPrice".get_v_scroll()
onready var shop_text = $"Shop UI/Shop Keeper Text Info"
onready var anim = $Anim
onready var hand_confirm = $"Shop UI/Hand Confirm"
onready var unit_picker = $"Unit Picker Solo"

# Shop text strings
const welcome_msg = "Welcome!\nいらっしゃいませ！"
const confirm = "Is that the one?こちらいいですか？\n        Yes/はい     No/いいえ"
const browsing = "Anything you like?\nお手伝いしましょうか？"
const not_enough_money = "You don't have enough money!\n足りないみたいです。"
const inventory_full = "Your inventory is full!\nインベントリーが一杯ですよ"
const thank_you = "Thank you for your patronage!\n毎度ありがとうございましす！"
const thanks_for_coming = "Come back soon!\nまた来てちょうだいね！"

# Debug Test variables
var unit_inventory_space = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	# Disable input
	set_process_input(false)
	
	# Reset all other variables
	reset()
	
	# Disable scroll bar with mouse
	scroll_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll_bar.modulate = Color(1,1,1,0)
	scroll_bar2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Signal for bar
	shop_list.get_v_scroll().connect("value_changed", self, "_adjust_hand_value")
	
	# Set Hand
	hand_selector.rect_position = STARTING_HAND_POSITION

func sell_item():
	# Remove item from the unit's inventory
	
	# Increase gold amount by item's worth
	pass 

func buy_item(index):
	# Set confirm buy back to 0
	confirm_buy_index = 0
	
	# Check if there is enough money
	current_price = int(shop_list_price.get_item_text(current_index).substr(0, shop_list_price.get_item_text(current_index).length() - 1))
	if BattlefieldInfo.money >= current_price:
		# Pick the unit to send this
		# Set current state to unit pick
		current_state = SHOP_STATE.SELECT_UNIT
		
		# Start the other screen
		unit_picker.start()
		
		# Disable the store
		shop_list.unselect_all()
		shop_list.release_focus()
		shop_list_price.unselect_all()
		# set_process_input(false)
	else:
		# Cancel here
		$"Shop UI/Shop Not enough money".play()
		
		# Show text
		shop_text.percent_visible = 0
		shop_text.text = not_enough_money
		anim.play("Text Anim")
		
		# Move hand off
		hand_confirm.rect_position = OFF_SCREEN
		
		# Wait two seconds then back to buy
		set_process_input(false)
		yield(get_tree().create_timer(2),"timeout")
		
		# Back to browsing
		back_to_browing()

func start(shop_state):
	# Reset
	reset()
	
	# Set shop State
	current_state = shop_state
	
	# Set previous scroll value
	previous_scroll_value = 0
	
	# Set money
	$"Shop UI/Money".text = str(BattlefieldInfo.money)
	
	# Set Greeting
	shop_text.text = welcome_msg
	
	# Play Fade in
	$"Shop UI/Shop Music".play()
	$"Shop UI".visible = true
	$Anim.play("Fade")
	yield($Anim, "animation_finished")
	
	# Play Welcome!
	$"Shop UI/Shop Greeting JPN".play()
	
	# Reset the hand
	hand_selector.rect_position = STARTING_HAND_POSITION
	
	# Set text anim
	shop_text.percent_visible = 0
	anim.play("Text Anim")
	yield(anim,"animation_finished")
	
	# Allow input
	set_process_input(true)
	
	# Set selected item to the first one in the list
	current_index = 0
	shop_list.select(current_index)
	shop_list_price.select(current_index)
	shop_list.grab_focus()
	
	# Shop hand
	$"Hand Selector".visible = true

func exit():
	# Disallow input
	shop_list.unselect_all()
	shop_list.release_focus()
	shop_list_price.unselect_all()
	set_process_input(false)
	
	#　Play goodbye
	$"Shop UI/Shop Exit".play()
	
	# Put hand away
	$"Hand Selector".visible = false
	
	# Set goodbye text
	shop_text.percent_visible = 0
	shop_text.text = thanks_for_coming
	anim.play("Text Anim")
	yield(anim,"animation_finished")
	
	# Wait 1 second
	yield(get_tree().create_timer(1),"timeout")
	
	# Shop music
	$"Shop UI/Shop Music".stop()
	anim.play_backwards("Fade")
	yield(anim, "animation_finished")
	$"Shop UI".visible = false
	
	# Remove the shop text
	shop_text.percent_visible = 0
	shop_text.text = ""
	
	# Go to walkable map if we came from there
	if came_from_walkable_map:
		# Set to false
		came_from_walkable_map = false
		
		# Eirika can move again
		BattlefieldInfo.walkable_map.eirika_walk._back_to_walk()
		
		# Play Music
		BattlefieldInfo.walkable_map.music.play(0)
	else:
		# Start Prep screen again
		BattlefieldInfo.preparation_screen.turn_on_fade()
		
		# Start Music
		BattlefieldInfo.preparation_screen.play_song(BattlefieldInfo.preparation_screen.current_song)

func _input(event):
	# Get State
	match current_state:
		SHOP_STATE.BUY:
			# Accept button
			if Input.is_action_just_pressed("ui_accept"):
				# Remove Focus
				shop_list.unselect_all()
				shop_list_price.unselect_all()
				shop_list.release_focus()
				
				# Play are you sure?
				$"Shop UI/Shop is that okay".play()
				# Set new text
				set_process_input(false)
				shop_text.percent_visible = 0
				shop_text.text = confirm
				anim.play("Text Anim")
				
				# Allow Movement again
				yield(anim, "animation_finished")
				
				# Move hand to where it should be
				hand_confirm.rect_position = YES_POSITION
				set_process_input(true)
				
				# Set new state
				current_state = SHOP_STATE.CONFIRM_BUY
				

				
			elif Input.is_action_just_pressed("ui_cancel"):
				set_process_input(false)
				current_state = SHOP_STATE.OFF
				exit()
		SHOP_STATE.SELL:
			pass
		SHOP_STATE.CONFIRM_BUY:
			# Left and Right
			if Input.is_action_just_pressed("ui_left"):
				if confirm_buy_index == 1:
					confirm_buy_index = 0
					hand_confirm.rect_position = YES_POSITION
					hand_confirm.get_node("Move").play()
			elif Input.is_action_just_pressed("ui_right"):
				if confirm_buy_index == 0:
					confirm_buy_index = 1
					hand_confirm.rect_position = NO_POSITION
					hand_confirm.get_node("Move").play()
			# Accept button
			if Input.is_action_just_pressed("ui_accept"):
				hand_confirm.get_node("Accept").play()
				# Are we on no?
				if confirm_buy_index == 1:
					# Cancel and go back
					$"Shop UI/Shop dissapointed".play()
					# Disable input
					set_process_input(false)
					
					# Send the hand back
					hand_confirm.rect_position = Vector2(-300,-300)
					# back to the Buy state
					current_state = SHOP_STATE.BUY
					# Back to browsing
					back_to_browing()
				else:
					current_state = SHOP_STATE.OFF
					buy_item(current_index)
			
			# Return button
			if Input.is_action_just_pressed("ui_cancel"):
				hand_confirm.get_node("Cancel").play()
				# Cancel and go back
				$"Shop UI/Shop Select your weapon".play()
				# Send the hand back
				hand_confirm.rect_position = Vector2(-300,-300)
				# back to the Buy state
				current_state = SHOP_STATE.BUY
				# Back to browsing
				back_to_browing()
		SHOP_STATE.CONFIRM_SELL:
			pass
		SHOP_STATE.SELECT_UNIT:
			# Cancel the purchase
			if Input.is_action_just_pressed("ui_cancel"):
				# Move Hand off
				hand_confirm.rect_position = OFF_SCREEN
				# Update amount left
				$"Shop UI/Money".text = str(BattlefieldInfo.money)
				
				# Hide the unit picker
				unit_picker.exit()
				
				$"Shop UI/Shop dissapointed".play()
				# Disable input
				set_process_input(false)
				
				# Send the hand back
				hand_confirm.rect_position = Vector2(-300,-300)
				# back to the Buy state
				current_state = SHOP_STATE.BUY
				# Back to browsing
				back_to_browing()
				

# Back to browsing
func back_to_browing():
	# Reset
	confirm_buy_index = 0
	confirm_sell_index = 0
	
	# Set text back
	shop_text.percent_visible = 0
	shop_text.text = browsing
	anim.play("Text Anim")
	
	# Wait
	yield(anim, "animation_finished")
	
	# Set state back
	current_state = SHOP_STATE.BUY
	
	# Move Hand away
	hand_confirm.rect_position = OFF_SCREEN
	
	# Set focus back on the first list
	shop_list.grab_focus()
	
	# Allow input again
	set_process_input(true)
	# Set selection back
	shop_list.select(current_index)
	shop_list_price.select(current_index)

# Whenever an item is selected
func _on_ShopList_item_selected(index):
	# Set current index
	current_index = index
	
	# Select the other side
	shop_list_price.select(index)
	
	# Move hand
	if Input.is_action_pressed("ui_up"):
		hand_selector.rect_position -= HAND_Y_INCREASE
	
	if Input.is_action_pressed("ui_down"):
		hand_selector.rect_position += HAND_Y_INCREASE
	
	# Play cursor sound
	hand_selector.get_node("Move").play()

# Adjust hand value when the scroll changes
func _adjust_hand_value(value):
	# Set the second scroll bar value to the first one
	scroll_bar2.value = scroll_bar.value
	
	# Did the Value go up?
	if previous_scroll_value > value:
		hand_selector.rect_position += HAND_Y_INCREASE
	else:
		hand_selector.rect_position -= HAND_Y_INCREASE
	
	# Set new previous value
	previous_scroll_value = value

func reset():
	confirm_buy_index = 0
	confirm_sell_index = 0
	current_index = 0
	
	# Set the value back to for the scroll value
	scroll_bar.value = 0
	scroll_bar2.value = 0

func check_unit_inventory_space(unit):
	if unit.UnitInventory.inventory.size() == Unit_Inventory.MAX_INVENTORY:
		return false
	return true

func _on_Unit_Picker_Solo_unit_picked(unit):
	# Check if we have inventory space
		if check_unit_inventory_space(unit):
			# Hide the unit picker
			unit_picker.exit()
			# Remove amount
			BattlefieldInfo.money -= current_price
			
			# Create the item
			unit.UnitInventory.add_item(BattlefieldInfo.item_database.create_item(ALL_ITEMS_REF.all_items[shop_list.get_item_text(current_index)]))
			
			# Move Hand off
			hand_confirm.rect_position = OFF_SCREEN
			# Update amount left
			$"Shop UI/Money".text = str(BattlefieldInfo.money)
			# Thanks for buying!
			$"Shop UI/Shop Exit JPN Patronage".play()
			# Set Text
			shop_text.percent_visible = 0
			shop_text.text = thank_you
			anim.play("Text Anim")
			# Wait two seconds then back to buy
			set_process_input(false)
			yield(get_tree().create_timer(2),"timeout")
			
			# Back to browsing
			back_to_browing()
			
			# Set back to select
			shop_list.select(current_index)
			shop_list_price.select(current_index)
			
		else:
			# Play can't do that
			$"Shop UI/Shop Can't do that".play()
			# Move Hand off
			hand_confirm.rect_position = OFF_SCREEN
			# Show text
			shop_text.percent_visible = 0
			shop_text.text = inventory_full
			anim.play("Text Anim")
			
			yield(get_tree().create_timer(2),"timeout")
