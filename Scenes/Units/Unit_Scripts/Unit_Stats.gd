extends Object

# Statistics for the unit 
class_name Unit_Stats

# UI attributes
var name
var class_type

# Level
var level = 1
var current_xp = 0

# Class Points for Xp
var class_bonus_a = 0
var class_bonus_b = 0
var class_power = 3
var boss_bonus = 0
var thief_bonus = 0

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
var bonus_crit = 0
var bonus_dodge = 0
var bonus_hit = 0

# Stat upgrade probability
var str_chance = 0
var skill_chance = 0
var speed_chance = 0
var magic_chance = 0
var luck_chance = 0
var def_chance = 0
var res_chance = 0
var consti_chance = 0
var max_health_chance = 0

# Max stat possible
const MAX_STAT = 30
const MAX_LEVEL = 20
const NEXT_LEVEL_XP = 100

# Damage calculations
var horse = false
var pegasus = false
var armor = false

func _init():
	name = "PLACERHOLDER"
	class_type = "PLACEHOLDER"
