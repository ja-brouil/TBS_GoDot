extends Node

class_name TileUnitUpdater

signal update_done

# Not sure why the yield doesn't work inside another function
var healed
var damaged

# This system will update each unit on tiles. Add what you need here
func ally_turn_update():
	for ally_unit in BattlefieldInfo.ally_units.values():
		damage(ally_unit, ally_unit.UnitMovementStats.currentTile)
		heal(ally_unit, ally_unit.UnitMovementStats.currentTile)
		
		if healed || damaged:
			yield(get_tree().create_timer(1), "timeout")
	emit_signal("update_done", "Ally")

func enemy_turn_update():
	for enemy_unit in BattlefieldInfo.enemy_units.values():
		damage(enemy_unit, enemy_unit.UnitMovementStats.currentTile)
		heal(enemy_unit, enemy_unit.UnitMovementStats.currentTile)
		if healed || damaged:
			yield(get_tree().create_timer(1), "timeout")
	emit_signal("update_done", "Enemy")

func heal(unit, tile):
	healed = false
	# Do not process if unit is at max health
	if unit.UnitStats.current_health == unit.UnitStats.max_health:
		return
		
	match tile.tileName:
		"Fortress":
			# 20% Heal
			unit.UnitStats.current_health += int(round(unit.UnitStats.max_health * 0.2))
			set_healed_status(unit)
		"Heal Tile":
			# 10% Heal
			unit.UnitStats.current_health += int(round(unit.UnitStats.max_health * 0.1))
			set_healed_status(unit)
		"Throne":
			# 25% heal
			unit.UnitStats.current_health += int(round(unit.UnitStats.max_health * 0.25))
			set_healed_status(unit)
	
	# Clamp HP
	unit.UnitStats.current_health = clamp(unit.UnitStats.current_health, 1, unit.UnitStats.max_health)

func damage(unit, tile):
	damaged = false
	# Flying units are not affected by damage
	if unit.UnitStats.pegasus:
		return
		
	match tile.tileName:
		"Lava", "Poison":
			# 10% Damage
			unit.UnitStats.current_health -= int(round(unit.UnitStats.max_health * 0.1))
			set_camera_position(unit)
			$"Damage Sound".play(0)
			damaged = true
	
	# Clamp HP | Should units die from taking too much enviromental damage?
	unit.UnitStats.current_health = clamp(unit.UnitStats.current_health, 1, unit.UnitStats.max_health)

func set_healed_status(unit):
	# Move camera and play sound
	set_camera_position(unit)
	$"Heal Sound".play(0)
	healed = true

# Anything else
func misc_tiles(unit, tile):
	pass

# Set Camera
func set_camera_position(unit):
	BattlefieldInfo.main_game_camera.position = (unit.position + Vector2(-112, -82))
	BattlefieldInfo.main_game_camera.clampCameraPosition()
	BattlefieldInfo.cursor.position = unit.position