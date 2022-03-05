extends Node

onready var timer = $Timer
onready var world = get_parent()

signal end_turn;

func on_turn_enter():
	var units = world.get_node("EnemyUnits").get_children()
	var gridMap = world.get_node("GridMap")

	for unit in units:
		timer.start()
		var map_pos = gridMap.world_to_map(unit.translation)
		var available_tiles = world.get_available_movement_tiles(map_pos.x, map_pos.z, unit.movement_range, unit.movement_pattern)
		var tile = available_tiles[randi() % available_tiles.size()]
		unit.translation = Vector3(tile.x+0.5, 0.5, tile.y+0.5)
		unit.moved = true
		yield(timer, "timeout")
	
	emit_signal("end_turn")
