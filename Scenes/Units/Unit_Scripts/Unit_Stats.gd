# Statistics for the unit 
class_name Unit_Stats

# UI attributes
var name
var class_type

# Regular attributes
var max_health = 20
var current_health = 20
const MAX_POSSIBLE_HEALTH = 60

var strength = 5 # Physical damage
var skill    = 5 # Accuracy Rate
var speed    = 5 # Double attack rate and avoidance
var magic    = 5 # Magic Damage
var luck     = 5 # Critical strike chance and avoidance
var def      = 5 # Physical damage defence
var res      = 5 # Magical damage defence
var consti   = 5 # Allows to wield heavier weapons

# Bonuses
var bonus_crit = 1
var bonus_dodge = 1
var bonus_hit = 1

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