extends KinematicBody2D

var  dialogue = ["Naomi@assets/units/archer/Naomi.png@My lady Eirika! I'm sorry I didn't notice you there!",
	"Eirika@assets/units/eirika/eirika mugshot.png@I'm sorry, I didn't mean to interrupt what you were doing.",
	"Naomi@assets/units/archer/Naomi.png@Oh not at all! I was target practicing! Gotta keep these bow skills sharp!",
	"Eirika@assets/units/eirika/eirika mugshot.png@I am very glad to have you on our team Naomi!",
	"Naomi@assets/units/archer/Naomi.png@Anytime my lady! You know with my bow skills, I can hit enemies from far away and they can't do a single thing about it!",
	"Naomi@assets/units/archer/Naomi.png@We strike them and soften them up first!",
	"Naomi@assets/units/archer/Naomi.png@Of course, if they get up close and personal...",
	"Eirika@assets/units/eirika/eirika mugshot.png@Do not worry about that! We are here to protect you!",
	"Naomi@assets/units/archer/Naomi.png@Yay! I knew I can count on you my lady!"
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	$Animation.play("Idle")

func start_dialogue():
	BattlefieldInfo.message_system.start(dialogue)
