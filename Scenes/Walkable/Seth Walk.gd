extends KinematicBody2D

var talk_name = "Seth"

var  dialogue = ["Seth@assets/units/cavalier/seth mugshot.png@Your highness, these are the training grounds.",
	"Seth@assets/units/cavalier/seth mugshot.png@We can train our units, make preparations and make alliances with other kingdoms.",
	"Eirika@assets/units/eirika/eirika mugshot.png@It seems a bit empty at the moment. Can we build more facilities?",
	"Seth@assets/units/cavalier/seth mugshot.png@At the current moment we don't have anyone capable of building such facilities.We are also going to need resources.",
	"Eirika@assets/units/eirika/eirika mugshot.png@Thank you Seth, I'll check back in when we do.",]

# Called when the node enters the scene tree for the first time.
func _ready():
	$Animation.play("Idle")

func start_dialogue():
	BattlefieldInfo.message_system.start(dialogue)
