extends Node

signal finished_turn

onready var level = get_parent() 

func find_closest_unit(from: Vector3, units: Array):
	if len(units) == 0:
		return null
	var closest = units[0]
	for i in range(1, len(units)):
		if from.distance_squared_to(closest.translation) < from.distance_squared_to(units[i].translation):
			closest = units[i]
	return closest

func find_best_move(available_moves: Array, current_position: Vector3, target_position: Vector3):
	if len(available_moves) == 0:
		return null
	var closest_move = null
	for move in available_moves:
		var dist = move.distance_squared_to(target_position)
		print(move, " ", dist, " ", current_position.distance_squared_to(target_position))
		if closest_move == null:
			if dist < current_position.distance_squared_to(target_position):
				closest_move = move
		else:
			if dist < closest_move.distance_squared_to(target_position):
				closest_move = move
	return closest_move

func _on_BaseLevel_enemy_phase_enter():
	var enemy_units = level.get_enemy_units()
	var player_units = level.get_player_units()
	
	yield(get_tree().create_timer(0.2), "timeout")
	
	for i in range(len(enemy_units)):
		var unit = enemy_units[i]
		var available_moves = level.get_available_moves(unit)#world.get_available_movement_tiles(map_pos.x, map_pos.z, unit.movement_range, unit.movement_pattern)		
		var target = find_closest_unit(unit.translation, player_units)
		var tile
		if target != null:
			#var target_pos = gridMap.world_to_map(target.translation)
			tile = find_best_move( \
				available_moves, \
				unit.translation, \
				target.translation \
			)
		else:
			tile = available_moves[randi() % len(available_moves)]
		
		if tile:
			level.world.move_unit(unit.translation, tile)
		
			#unit.get_node("StepSoundPlayer").play()
			yield(get_tree().create_timer(0.5), "timeout")
	

	yield(get_tree().create_timer(0.1), "timeout")
	emit_signal("finished_turn")
