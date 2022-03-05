extends Node

onready var timer = $Timer
onready var world = get_parent()

signal end_turn;

func assign_targets(enemy_units, player_units):
	return player_units

func find_best_move(available_moves: Array, current_position: Vector2, target_position: Vector2):
	if len(available_moves) == 0:
		return null
	var closest_move = null
	for move in available_moves:
		var dist = move.distance_to(target_position)
		if closest_move == null:
			if dist < current_position.distance_to(target_position):
				closest_move = move
		else:
			if dist < closest_move.distance_to(target_position):
				closest_move = move
	return closest_move

func on_turn_enter():
	var enemy_units = world.get_node("EnemyUnits").get_children()
	var player_units = world.get_node("PlayerUnits").get_children()
	var targets_per_enemy = assign_targets(enemy_units, player_units)
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	var gridMap = world.get_node("GridMap")
	for i in range(len(enemy_units)):
		var unit = enemy_units[i]
		
		var map_pos = gridMap.world_to_map(unit.translation)
		var available_moves = world.get_available_movement_tiles(map_pos.x, map_pos.z, unit.movement_range, unit.movement_pattern)
		
		var target = targets_per_enemy[i]
		var tile
		if target != null:
			var target_pos = gridMap.world_to_map(target.translation)
			tile = find_best_move( \
				available_moves, \
				Vector2(map_pos.x, map_pos.z), \
				Vector2(target_pos.x, target_pos.z) \
			)
		else:
			tile = available_moves[randi() % len(available_moves)]
		
		if tile:
			unit.translation = Vector3(tile.x+0.5, 0.5, tile.y+0.5)
			unit.moved = true
		
			timer.start()
			unit.get_node("StepSoundPlayer").play()
			yield(timer, "timeout")
	

	yield(get_tree().create_timer(0.1), "timeout")
	emit_signal("end_turn")
