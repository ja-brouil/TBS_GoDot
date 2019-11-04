# Statistics for the unit 
class_name Unit_Stats

# UI attributes
var name
var class_type

# Regular attributes
var max_health
var current_health
const MAX_POSSIBLE_HEALTH = 60

var strength # Physical damage
var skill    # Accuracy Rate
var speed    # Double attack rate and avoidance
var magic    # Magic Damage
var luck     # Critical strike chance and avoidance
var def      # Physical damage defence
var res      # Magical damage defence
var consti   # Allows to wield heavier weapons

# Bonuses
var bonus_crit
var bonus_dodge
var bonus_hit

# Stat upgrade probability
var str_chance
var skill_chance
var speed_chance
var magic_chance
var luck_chance
var def_chance
var res_chance
var consti_chance
var max_health_chance

# Max stat possible
const MAX_STAT = 30

func _init():
	name = "PLACERHOLDER"
	class_type = "PLACEHOLDER"