extends Node2D

# Map information
export var map_height: int # cell size
export var map_width: int # cell size
var all_allies_location = {} # Holds all ally info
var all_enemies_location = {} # holds all enemy info
var grid = [] # Holds all cell data
var cell = preload("res://Scenes/GUI/Cell/Cell.tscn")

# Map information has been loaded
signal mapInformationLoaded

# Called when the node enters the scene tree for the first time.
func _ready():
	# Current Level set
	BattlefieldInfo.current_level = self
	
	# Set music volume
	BattlefieldInfo.music_player.get_node("AllyLevel").volume_db = 0
	
	# Set Map height
	map_height = self.get_meta("height")
	map_width = self.get_meta("width")
	
	# Set Map victory condition
	BattlefieldInfo.victory_text = self.get_meta("Victory_Condition")
	
	# Clear Battlefield arrays
	BattlefieldInfo.spawn_points.clear()
	BattlefieldInfo.swap_points.clear()
	
	# Start 2D Array
	for i in map_width:
		grid.append([])
		for j in map_height:
			grid[i].append(0)
	
	# Cell information
	# [height, type, visible, width, Avd, Def, MovementCost, TileType] -> Tile String Names
	var cellInfoLayer = $"CellInfo"
	for cellInfo in cellInfoLayer.get_children():
		var map_cell_info = cell.instance()
		
		# Initialize the cell
		map_cell_info.init(Vector2(cellInfo.position.x / Cell.CELL_SIZE, cellInfo.position.y / Cell.CELL_SIZE), \
		cellInfo.get_meta("Avd"), cellInfo.get_meta("Def"), cellInfo.get_meta("MovementCost"), cellInfo.get_meta(("TileType")))
		
		# Set name
		map_cell_info.set_name("map_cell")
		
		# Check if it's a spawn point
		if cellInfo.has_meta("Spawn"):
			map_cell_info.is_spawn_point = true
			BattlefieldInfo.spawn_points.append(map_cell_info)
		
		# Check for swap points for swap screen
		if cellInfo.has_meta("Swap"):
			BattlefieldInfo.swap_points.append(map_cell_info)
		
		# Add as child and set cell to grid
		add_child(map_cell_info)
		grid[cellInfo.position.x / Cell.CELL_SIZE][cellInfo.position.y / Cell.CELL_SIZE] = map_cell_info
	# Set Adj Cells
	for cellArray in grid:
		for cell in cellArray:
			# Left
			if cell.getPosition().x - 1 >= 0:
				cell.adjCells.append(grid[cell.getPosition().x - 1][cell.getPosition().y])
			# Right
			if cell.getPosition().x + 1 < map_width:
				cell.adjCells.append(grid[cell.getPosition().x + 1][cell.getPosition().y])
			# Up
			if cell.getPosition().y - 1 >= 0:
				var cellToAdd = grid[cell.getPosition().x][cell.getPosition().y - 1]
				cell.adjCells.append(cellToAdd)
			# Down
			if cell.getPosition().y + 1 < map_height:
				cell.adjCells.append(grid[cell.getPosition().x][cell.getPosition().y + 1])
	
	# Load Units Information
	all_allies_location.clear()
	all_enemies_location.clear()
	var allyInfoLayer = $"Allies"
	var enemyInfoLayer = $"Enemies"
	
	for allyCellInfo in allyInfoLayer.get_children():
		# Do we already have this ally?
		var ally_name = allyCellInfo.get_meta("Identifier")
		
		if BattlefieldInfo.ally_units.has(ally_name):
			BattlefieldInfo.ally_units[ally_name].position.x = allyCellInfo.position.x
			BattlefieldInfo.ally_units[ally_name].position.y = allyCellInfo.position.y
			BattlefieldInfo.ally_units[ally_name].visible = false
			BattlefieldInfo.ally_units[ally_name].modulate = Color(1,1,1,1)
			BattlefieldInfo.ally_units[ally_name].UnitActionStatus.set_current_action(Unit_Action_Status.MOVE)
			
			# Grid info
			BattlefieldInfo.ally_units[ally_name].UnitMovementStats.currentTile = grid[BattlefieldInfo.ally_units[ally_name].position.x / Cell.CELL_SIZE][BattlefieldInfo.ally_units[ally_name].position.y / Cell.CELL_SIZE]
			grid[BattlefieldInfo.ally_units[ally_name].position.x / Cell.CELL_SIZE][BattlefieldInfo.ally_units[ally_name].position.y / Cell.CELL_SIZE].occupyingUnit = BattlefieldInfo.ally_units[ally_name]
	
	# Set HP Status back to max
	for ally_unit_to_heal in BattlefieldInfo.ally_units.values():
		ally_unit_to_heal.UnitStats.current_health = ally_unit_to_heal.UnitStats.max_health
		
	# Create Enemy Units
	for enemy in enemyInfoLayer.get_children():
		var path = str("res://Scenes/Units/Enemy_Units/", enemy.get_meta("InstanceName"),".tscn")
		var newEnemy = load(path).instance()
		
		# Set AI Type
		newEnemy.get_node("AI").ai_type = enemy.get_meta("aiType")
		$YSort.add_child(newEnemy)
		
		# Set Stats
		newEnemy.position = Vector2(enemy.position.x, enemy.position.y)
		newEnemy.UnitStats.name = enemy.get_meta("Name")
		newEnemy.UnitStats.strength = enemy.get_meta("Str")
		newEnemy.UnitStats.skill = enemy.get_meta("Skill")
		newEnemy.UnitStats.speed = enemy.get_meta("Speed")
		newEnemy.UnitStats.magic = enemy.get_meta("Magic")
		newEnemy.UnitStats.luck = enemy.get_meta("Luck")
		newEnemy.UnitStats.def = enemy.get_meta("Defense")
		newEnemy.UnitStats.res = enemy.get_meta("Res")
		newEnemy.UnitStats.consti = enemy.get_meta("Consti")
		newEnemy.UnitStats.bonus_crit = enemy.get_meta("BonusCrit")
		newEnemy.UnitStats.bonus_dodge = enemy.get_meta("BonusDodge")
		newEnemy.UnitStats.bonus_hit = enemy.get_meta("BonusHit")
		newEnemy.UnitStats.level = enemy.get_meta("Level")
		newEnemy.UnitStats.class_type = enemy.get_meta("Class")
		newEnemy.UnitStats.current_health = enemy.get_meta("Health")
		newEnemy.UnitStats.max_health = enemy.get_meta("MaxHealth")
		
		# Movement stats
		newEnemy.UnitMovementStats.movementSteps = enemy.get_meta("Move")
		
		# XP Stats
		newEnemy.UnitStats.class_power = enemy.get_meta("ClassPower")
		newEnemy.UnitStats.class_bonus_a = enemy.get_meta("ClassBonusA")
		newEnemy.UnitStats.class_bonus_b = enemy.get_meta("ClassBonusB")
		newEnemy.UnitStats.boss_bonus = enemy.get_meta("BossBonus")
		newEnemy.UnitStats.thief_bonus = enemy.get_meta("ThiefBonus")
		
		# Identifier
		newEnemy.UnitStats.identifier = enemy.get_meta("Identifier")
		
		# Set Battlefield Info
		newEnemy.UnitMovementStats.is_ally = false
		newEnemy.UnitMovementStats.currentTile = grid[newEnemy.position.x / Cell.CELL_SIZE][newEnemy.position.y / Cell.CELL_SIZE]
		grid[newEnemy.position.x / Cell.CELL_SIZE][newEnemy.position.y / Cell.CELL_SIZE].occupyingUnit = newEnemy
		all_enemies_location[enemy.get_meta("Identifier")] = newEnemy
	
	# Send cell and grid information to the battlefield main so it is easily accessible
	BattlefieldInfo.grid = self.grid
	BattlefieldInfo.map_height = self.map_height
	BattlefieldInfo.map_width = self.map_width
	BattlefieldInfo.enemy_units = self.all_enemies_location
	
	# Load the information for the map into the camera
	BattlefieldInfo.main_game_camera._on_Level_mapInformationLoaded()