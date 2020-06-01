extends CanvasLayer

class_name Shop_UI

# Shop UI
# Inventory for the shop
const item_shop = {}

# Current index
var current_index = 0

# Index for Buy/Sell
var buy_sell_index_choice = 0

# Scroll bar p value
var previous_scroll_value = 0

# State machine for the shop
enum SHOP_STATE {ASK, BUY, SELL, CONFIRM_BUY, CONFIRM_SELL, SELECT_UNIT, SELL_SELECT_UNIT, OFF}
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

# Current unit selected
var current_unit_selected = null

# Test for walkable map
var came_from_walkable_map = false

# Selling variables
var item_to_sell = null

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
const buy_sell = "What will it be? 何をしますか？\n        Buy/買う     Sell/売る"
const confirm =  "Is that the one?それがいいですか？\n        Yes/はい     No/いいえ"
const select_unit_to_sell = "Please select a unit.\n 仲間を選んでください"
const sell_message = "What would you like to sell?\n　何を売りますか？"
const cant_buy_that_item = "Sorry, I can't buy that.\n ごめん、それが買えません。"
const no_items_to_sell = "Sorry, but you don't have any items to sell\n ごめん、アイテムがありません。"
const browsing = "Anything you like?\n武器を選択してください。"
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
	#hand_selector.rect_position = STARTING_HAND_POSITION

func sell_item(item_to_be_sold):
	# Shop status
	current_state = SHOP_STATE.OFF
	
	# Move the hand away
	$"Shop UI/Hand Confirm".rect_position = OFF_SCREEN
	
	# Set the confirm back to 0
	confirm_sell_index = 0
	item_to_sell = null
	
	# Remove item from the unit's inventory
	current_unit_selected.UnitInventory.remove_item(item_to_be_sold)
	
	# Increase gold amount by item's worth
	BattlefieldInfo.money += item_to_be_sold.get_selling_cost()
	
	# Set the money
	$"Shop UI/Money".text = str(BattlefieldInfo.money)
	
	# Set new text
	$"Shop UI/Shop Exit JPN Patronage".play()
	
	# Set Text
	shop_text.percent_visible = 0
	shop_text.text = thank_you
	anim.play("Text Anim")
	# Wait two seconds then back to buy
	set_process_input(false)
	yield(get_tree().create_timer(1.5),"timeout")
	
	# Back to unit inventory
	current_state = SHOP_STATE.SELL_SELECT_UNIT
	
	# Start the Inventory again
	# Set Text
	shop_text.percent_visible = 0
	shop_text.text = sell_message
	anim.play("Text Anim")
	# Wait two seconds then back to buy
	yield(anim,"animation_finished")
	
	# Open the Unit Inventory Display
	$"Unit Inventory Display".populate_list_of_items(current_unit_selected)
	
	# Allow input
	$"Unit Inventory Display".allow_input()
	set_process_input(true)
	
	# Go back to sell
	current_state = SHOP_STATE.SELL

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
		unit_picker.start_with_convoy()
		
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

func start():
	# Reset
	reset()
	
	# Set shop State
	current_state = SHOP_STATE.ASK
	
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
	
	# Set text anim for greeting
	shop_text.percent_visible = 0
	anim.play("Text Anim")
	yield(get_tree().create_timer(1.5), "timeout")
	
	# Show buy//sell option next
	shop_text.percent_visible = 0
	shop_text.text = buy_sell
	anim.play("Text Anim")
	yield(anim,"animation_finished")
	
	# Reset the hand to the yes position
	hand_selector.rect_position = YES_POSITION
	
	# Allow input and disable the shop list for now
	shop_list.focus_mode = Control.FOCUS_NONE
	set_process_input(true)
	
	# Set index
	current_index = 0
	
	# Shop hand
	$"Shop UI/Hand Confirm".visible = true
	$"Shop UI/Hand Confirm".rect_position = YES_POSITION

func allow_list_input():
	shop_list.focus_mode = Control.FOCUS_ALL
	shop_list.select(current_index)
	shop_list_price.select(current_index)
	shop_list.grab_focus()

func exit():
	# Disallow input
	shop_list.unselect_all()
	shop_list.release_focus()
	shop_list_price.unselect_all()
	set_process_input(false)
	
	#　Play goodbye
	$"Shop UI/Shop Exit".play()
	
	# Put hand away
	$"Shop UI/Hand Confirm".visible = false
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
		SHOP_STATE.ASK:
		# Left and Right
			if Input.is_action_just_pressed("ui_left"):
				if buy_sell_index_choice == 1:
					buy_sell_index_choice = 0
					hand_confirm.rect_position = YES_POSITION
					hand_confirm.get_node("Move").play()
			elif Input.is_action_just_pressed("ui_right"):
				if  buy_sell_index_choice == 0:
					buy_sell_index_choice = 1
					hand_confirm.rect_position = NO_POSITION
					hand_confirm.get_node("Move").play()
			elif Input.is_action_just_pressed("ui_accept"):
				hand_confirm.get_node("Accept").play()
				# Are we on sell?
				if buy_sell_index_choice == 1:
					# Send the hand back
					hand_confirm.rect_position = Vector2(-300,-300)
					
					# back to the Buy state
					current_state = SHOP_STATE.SELL_SELECT_UNIT
					
					# Set new message
					set_process_input(false)
					shop_text.percent_visible = 0
					shop_text.text = select_unit_to_sell
					anim.play("Text Anim")
				
					# Allow Movement again
					yield(anim, "animation_finished")
					set_process_input(true)
					
					# Start the solo picker
					select_unit_for_inventory()
				else:
					current_state = SHOP_STATE.OFF
					$"Shop UI/Hand Confirm".rect_position = OFF_SCREEN
					back_to_browing()
					$"Shop UI/Shop Select your weapon".play()
					allow_list_input()
			elif Input.is_action_just_pressed("ui_cancel"):
				set_process_input(false)
				current_state = SHOP_STATE.OFF
				exit()
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
				# Go back to buy/sell
				current_state = SHOP_STATE.ASK
				
				# Disable list
				shop_list.unselect_all()
				shop_list_price.unselect_all()
				shop_list.release_focus()
				
				# Show buy//sell option next
				shop_text.percent_visible = 0
				shop_text.text = buy_sell
				anim.play("Text Anim")
				yield(anim,"animation_finished")
				
				# Bring hand back
				$"Shop UI/Hand Confirm".rect_position = YES_POSITION
		SHOP_STATE.SELL_SELECT_UNIT:
			# Back to ask
			if Input.is_action_just_pressed("ui_cancel"):
				# Go back to unit picker
				# Send the hand back
				hand_confirm.rect_position = OFF_SCREEN
				# Back to the sell state
				current_state = SHOP_STATE.ASK
				
				# Close the unit display
				$"Unit Picker Solo".exit()
				
				# Change text
				set_process_input(false)
				shop_text.percent_visible = 0
				shop_text.text = buy_sell
				anim.play("Text Anim")
				yield(anim, "animation_finished")
				set_process_input(true)
				
				# Bring hand back
				$"Shop UI/Hand Confirm".rect_position = YES_POSITION
				
				# Reset
				reset()
				
		SHOP_STATE.SELL:
			if Input.is_action_just_pressed("ui_cancel"):
				# Go back to unit picker
				# Send the hand back
				hand_confirm.rect_position = OFF_SCREEN
				# Back to the sell state
				current_state = SHOP_STATE.SELL_SELECT_UNIT
				
				# Go back to picking the weapon
				select_unit_for_inventory()
				
				# Change text
				shop_text.percent_visible = 0
				shop_text.text = select_unit_to_sell
				anim.play("Text Anim")
				
				# Hide the Inventory
				$"Unit Inventory Display".exit()
				
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
					current_state = SHOP_STATE.OFF
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
			# Left and Right
			if Input.is_action_just_pressed("ui_left"):
				if confirm_sell_index == 1:
					confirm_sell_index = 0
					hand_confirm.rect_position = YES_POSITION
					hand_confirm.get_node("Move").play()
			elif Input.is_action_just_pressed("ui_right"):
				if confirm_sell_index == 0:
					confirm_sell_index = 1
					hand_confirm.rect_position = NO_POSITION
					hand_confirm.get_node("Move").play()
			# Accept button
			elif Input.is_action_just_pressed("ui_accept"):
				# Are we on no?
				if confirm_sell_index == 1:
					# Cancel and go back
					$"Shop UI/Shop dissapointed".play()
					
					# Cancel and go back
					hand_confirm.get_node("Cancel").play()
					
					# Set sell index back to 0
					confirm_sell_index = 0
					
					# New Message
					shop_text.percent_visible = 0
					shop_text.text = sell_message
					anim.play("Text Anim")
					
					# Send the hand back
					hand_confirm.rect_position = OFF_SCREEN
					# Back to the sell state
					current_state = SHOP_STATE.SELL
					# Go back to picking the weapon
					$"Unit Inventory Display".allow_input_last_pick()
				else:
					hand_confirm.get_node("Accept").play()
					current_state = SHOP_STATE.OFF
					sell_item(item_to_sell)
			
			# Return button
			elif Input.is_action_just_pressed("ui_cancel"):
				hand_confirm.get_node("Cancel").play()
				confirm_sell_index = 0
				# Cancel and go back
				$"Shop UI/Shop Select your weapon".play()
				# Send the hand back
				hand_confirm.rect_position = OFF_SCREEN
				# Back to the sell state
				current_state = SHOP_STATE.SELL
				
				# New Message
				shop_text.percent_visible = 0
				shop_text.text = sell_message
				anim.play("Text Anim")
				
				# Go back to picking the weapon
				$"Unit Inventory Display".allow_input_last_pick()
				
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

# Set Select unit to sell to
func select_unit_for_inventory():
	# Bring up the Unit Picker Solo
	$"Unit Picker Solo".start_with_convoy()
	
	# Move hand off screen
	$"Shop UI/Hand Confirm".rect_position = OFF_SCREEN

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
	buy_sell_index_choice = 0
	current_unit_selected = null
	
	# Set the value back to for the scroll value
	scroll_bar.value = 0
	scroll_bar2.value = 0

func check_unit_inventory_space(unit):
	if unit.UnitInventory.inventory.size() == Unit_Inventory.MAX_INVENTORY:
		return false
	return true

func _on_Unit_Picker_Solo_unit_picked(unit):
	match current_state:
		SHOP_STATE.SELECT_UNIT:
			if unit == Convoy:
			# Hide the unit picker
				unit_picker.exit()
				# Remove amount
				BattlefieldInfo.money -= current_price
				
				# Create the item
				Convoy.get_node("Convoy UI").add_item_to_convoy(BattlefieldInfo.item_database.create_item(ALL_ITEMS_REF.all_items[shop_list.get_item_text(current_index)]))
				
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
		SHOP_STATE.SELL_SELECT_UNIT:
			# Convoy -> Implement later
			if unit == Convoy:
				# Disable this temporarily
				shop_list.unselect_all()
				shop_list_price.unselect_all()
				shop_list.release_focus()
				
				# Exit the unit solo picker
				$"Unit Picker Solo".exit()
				
				# Start the convoy
				Convoy.get_node("Convoy UI").start_on_sell()
				set_process_input(false)
			else:
				# Check if the unit's inventory is empty first
				if unit.UnitInventory.inventory.size() == 0:
					# Play can't do that
					$"Shop UI/Shop Can't do that".play()
					# Move Hand off
					hand_confirm.rect_position = OFF_SCREEN
					# Show text
					shop_text.percent_visible = 0
					shop_text.text = no_items_to_sell
					anim.play("Text Anim")
					
					yield(get_tree().create_timer(2),"timeout")
				else:
					# Save the unit to the variable
					current_unit_selected = unit
					
					# Play Sound
					$"Shop UI/Shop Select your weapon".play()
					
					# Disable the list
					shop_list.unselect_all()
					shop_list_price.unselect_all()
					shop_list.release_focus()
					
					# Set new instruction text
					shop_text.percent_visible = 0
					shop_text.text = sell_message
					anim.play("Text Anim")
					
					# Hide the Unit Picker
					$"Unit Picker Solo".exit()
					
					# Open the Unit Inventory Display
					$"Unit Inventory Display".start_with_input(unit)
					
					# Set to sell state
					current_state = SHOP_STATE.SELL
					

func _on_Unit_Inventory_Display_item_selected():
	# Set new item
	item_to_sell = $"Unit Inventory Display".current_item_selected
	
	# Check if this item can be sold
	if item_to_sell.get_selling_cost() < 0:
		# Stop inventory picking unit
		$"Unit Inventory Display".disallow_input()
		
		# Play can't do that
		$"Shop UI/Shop Can't do that".play()
		
		# Show text
		shop_text.percent_visible = 0
		shop_text.text = cant_buy_that_item
		anim.play("Text Anim")
		
		# Wait for ending
		yield(anim, "animation_finished")
		yield(get_tree().create_timer(0.5), "timeout")
		
		# Set new instruction text
		shop_text.percent_visible = 0
		shop_text.text = sell_message
		anim.play("Text Anim")
		
		# Wait for ending
		yield(anim, "animation_finished")
		
		# Allow input
		$"Unit Inventory Display".allow_input_last_pick()
		
	else:
		# Proceed to confirm sell
		# Disallow input
		# Stop inventory picking unit
		$"Unit Inventory Display".disallow_input()
		
		# Play are you sure?
		$"Shop UI/Shop is that okay".play()
		
		# Show text
		shop_text.percent_visible = 0
		shop_text.text = confirm
		anim.play("Text Anim")
		
		# Wait for ending
		yield(anim, "animation_finished")
		set_process_input(true)
		
		# Set new state of the shop
		current_state = SHOP_STATE.CONFIRM_SELL
		
		# Set hand to new location
		$"Shop UI/Hand Confirm".rect_position = YES_POSITION
		
		

func set_input_timer(input_value, var time = 0.5):
	yield(get_tree().create_timer(time), "timeout")
	set_process_input(input_value)
