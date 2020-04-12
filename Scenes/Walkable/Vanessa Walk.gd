extends KinematicBody2D

var  dialogue = ["Vanessa@assets/units/pegasus knight/Vanessa Portrait.png@Hi Eirika! Do you see these forests next to me?",
	"Eirika@assets/units/eirika/eirika mugshot.png@Yes I do! Forests seem to slow us down on the battlefield!",
	"Vanessa@assets/units/pegasus knight/Vanessa Portrait.png@Indeed they do! However, forests will give you bonus avoidance and bonus defense when you fight from them!",
	"Vanessa@assets/units/pegasus knight/Vanessa Portrait.png@Isn't that amazing!",
	"Eirika@assets/units/eirika/eirika mugshot.png@Oh I didn't know that! But, you are on a pegasus horse. You can fly over them easily.",
	"Vanessa@assets/units/pegasus knight/Vanessa Portrait.png@That's true! Units that can fly such as Pegasus Knights like myself don't have any movement penalties crossing over forests!",
	"Vanessa@assets/units/pegasus knight/Vanessa Portrait.png@But we don't get any extra defenses due to the fact that we are flying.",
	"Vanessa@assets/units/pegasus knight/Vanessa Portrait.png@That's fine with me anyways! I hate bugs! I'll stay up here in the sky.",
	"Eirika@assets/units/eirika/eirika mugshot.png@I am glad you are watching from the skies Vanessa!"
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	$Animation.play("Idle")

func start_dialogue():
	BattlefieldInfo.message_system.start(dialogue)
