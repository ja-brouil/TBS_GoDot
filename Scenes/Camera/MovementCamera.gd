extends Camera2D

func _ready():
	limit_bottom = BattlefieldInfo.map_height * Cell.CELL_SIZE
	limit_right = BattlefieldInfo.map_width * Cell.CELL_SIZE
