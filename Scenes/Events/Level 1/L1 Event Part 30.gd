extends Event_Base

class_name L1_Event_Part_30

# Event Description:
# Seth + Eirika chat for a bit

# Actors to move
var ewan
var natasha
var neimi
var gilliam
var vanessa

# Dialogue between the characters
var dialogue = [
	# Japanese
	"ゼト:\n\nやろう、市民を殺している！",
	"ゼト:\n\nアルマイリやンの兵士がいる！なぜ山賊に手伝ってあげる？",
	"エイリーカ:\n\nゼト騎士長！",
	"エイリーカ:\n\n一つの村をもう崩されています！",
	"エイリーカ:\n\n他の村を絶対に守ります！",
	"ゼト:\n\nええ、そうだね。しかしお父さんに娘を守る約束だ。危なすぎる場合は、王女が逃げろ。わかりましたか？それは俺の命令だ。",
	"エイリーカ:\n\nいいよ。みんな、行きましょう！"
	# English
#	"Seth:\n\nThose bastards! Attacking innocent townsfolk!",
#	"Seth:\n\nThere are Almaryan soldiers that are helping them as well!",
#	"Eirika:\n\nSeth! They have already destroyed a village!",
#	"Eirika:\n\nWe have to stop them before they can do anymore damage to the other villages!",
#	"Seth:\n\nI will hold the front line. If you get injured, you are to fall back immediately.",
#	"Eirika:\n\nI understand. Let's go!",
]

# Set Names for Debug
func _init():
	event_name = "Prepare for Battle"
	event_part = "Part 30"

func start():
	# Show allies
	ewan = BattlefieldInfo.ally_units["Ewan"]
	natasha = BattlefieldInfo.ally_units["Natasha"]
	neimi = BattlefieldInfo.ally_units["Neimi"]
	gilliam = BattlefieldInfo.ally_units["Gilliam"]
	vanessa = BattlefieldInfo.ally_units["Vanessa"]
	
	
	for enemy in BattlefieldInfo.enemy_units.values():
		enemy.visible = true
	
	# Register to the dialogue system
	BattlefieldInfo.message_system.connect("no_more_text", self, "move_actor")
	
	# Register Movement
	BattlefieldInfo.movement_system_cinematic.connect("unit_finished_moving_cinema", self, "move_cursor")
	
	# Start Text
	BattlefieldInfo.message_system.set_position(Messaging_System.TOP)
	enable_text(dialogue)

func move_cursor():
	BattlefieldInfo.cursor.position = Vector2(64, 208)
	event_complete()

func move_actor():
	for ally in BattlefieldInfo.ally_units.values():
		ally.visible = true
	
	# Build path to the location
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(natasha, BattlefieldInfo.grid[1][13], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(ewan, BattlefieldInfo.grid[3][14], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(neimi, BattlefieldInfo.grid[2][13], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(gilliam, BattlefieldInfo.grid[5][13], BattlefieldInfo.grid)
	BattlefieldInfo.movement_calculator.get_path_to_destination_AI(vanessa, BattlefieldInfo.grid[2][12], BattlefieldInfo.grid)
	
	# Remove original tile
	natasha.UnitMovementStats.currentTile.occupyingUnit = null
	ewan.UnitMovementStats.currentTile.occupyingUnit = null
	neimi.UnitMovementStats.currentTile.occupyingUnit = null
	gilliam.UnitMovementStats.currentTile.occupyingUnit = null
	vanessa.UnitMovementStats.currentTile.occupyingUnit = null
	
	# Add actors to movement
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(natasha)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(neimi)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(ewan)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(gilliam)
	BattlefieldInfo.movement_system_cinematic.unit_to_move_same_time.append(vanessa)
	
	# Start the cinematic movement
	BattlefieldInfo.movement_system_cinematic.is_moving = true