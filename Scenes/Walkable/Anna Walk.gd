extends KinematicBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Animation.play("Idle")

func start_dialogue():
	BattlefieldInfo.preparation_screen.get_node("Shop").came_from_walkable_map = true
	BattlefieldInfo.walkable_map.music.stop()
	BattlefieldInfo.walkable_map.eirika_walk.current_status = Eirka_Walk.STATUS.UI
	BattlefieldInfo.preparation_screen.get_node("Shop").start(Shop_UI.SHOP_STATE.BUY)
	
