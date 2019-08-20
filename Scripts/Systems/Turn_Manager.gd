# This class controls the system needed to pass between enemies and allies
extends Node

enum {PLAYER_TURN, ENEMY_TURN}
var turn

# Ally turn
# reset all allies to active
# Check if all the allies are on done status
# if they are -> turn over to enemy turn

# Enemy Turn
# Set all enemies to active
# Process all aggresive enemies
# process all passive enemies
# process all healers
# are we done processing all enemies?