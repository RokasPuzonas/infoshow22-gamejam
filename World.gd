extends Spatial

onready var Marker = load("res://CursorMarker.tscn")
onready var timer = $Timer
var current_marker

var selected_unit;
var available_moves;

export var end_turn = false
enum TURN{
	enemy
	player
}

var current_turn = TURN.player
func show_marker_at(x: int, y: int):
	if current_marker == null:
		current_marker = Marker.instance()
		add_child(current_marker)
	current_marker.visible = true
	current_marker.translation = Vector3(x, 1, y+1)

func hide_marker():
	if current_marker:
		current_marker.visible = false

func get_raycast_position():
	var cam = $Camera
	var mouse_pos = get_viewport().get_mouse_position()
	var space_state = get_world().direct_space_state
	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * 10000
	var cursorPos = space_state.intersect_ray(from, to)
	return cursorPos.get("position")

func get_tile_position():
	var pos = get_raycast_position()
	if pos:
		return $GridMap.world_to_map(pos)

func is_blocked(x, y):
	return $GridMap.get_cell_item(x, 0, y) == -1 || \
			$GridMap.get_cell_item(x, 1, y) == 3 || \
			get_unit_at(x, y) != null

func get_unit_at(x: int, y: int):
	for unit in $PlayerUnits.get_children():
		if unit.translation.x-0.5 == x && unit.translation.z-0.5 == y:
			return unit

func select_unit(unit):
	selected_unit = unit
	var Marker = load("res://MovementMarker.tscn")

	available_moves = []
	var map_pos = $GridMap.world_to_map(unit.translation)
	for tile in get_available_movement_tiles(map_pos.x, map_pos.z, unit.movement_range, unit.movement_pattern):
		available_moves.push_front(tile)

	$MoveMarkers.translation = Vector3(0.5, 0.5, 0.5)
	for tile in available_moves:
		var marker = Marker.instance()
		marker.translation = Vector3(tile.x, 0, tile.y)
		$MoveMarkers.add_child(marker)

func move_selected(pos):
	if !available_moves.has(Vector2(pos.x, pos.z)):
		return false
		
	selected_unit.translation = Vector3(0.5+pos.x, 0.5, 0.5+pos.z)
	selected_unit.moved = true
	deselect_unit()
	return true

func deselect_unit():
	selected_unit = null
	for marker in $MoveMarkers.get_children():
		$MoveMarkers.remove_child(marker)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		deselect_unit()

	var pos = get_tile_position();
	if pos != null:
		var unit_on_mouse = get_unit_at(pos.x, pos.z)
		if Input.is_action_just_pressed("mouse_press"):
			if selected_unit == null && unit_on_mouse != null and not unit_on_mouse.enemy and not unit_on_mouse.moved:
				select_unit(unit_on_mouse)
			elif selected_unit != null:
				if !move_selected(pos):
					deselect_unit()

		show_marker_at(pos.x, pos.z)
	else:
		hide_marker()

	if not end_turn:
		if current_turn == TURN.player:
			_reset_moved("EnemyUnits")
			_check_moves("PlayerUnits", TURN.enemy)

		elif current_turn == TURN.enemy:
			_reset_moved("PlayerUnits")
			_enemy_move()
			current_turn = TURN.player
	elif current_turn == TURN.player:
		_reset_moved("PlayerUnits")
		_enemy_move()
		end_turn = false

func _enemy_move():
	var units = get_node("EnemyUnits").get_children()

	for unit in units:
		timer.start()
		var map_pos = $GridMap.world_to_map(unit.translation)
		var available_tiles = get_available_movement_tiles(map_pos.x, map_pos.z, unit.movement_range, unit.movement_pattern)
		var tile = available_tiles[randi() % available_tiles.size()]
		unit.translation = Vector3(tile.x+0.5, 0.5, tile.y+0.5)
		unit.moved = true
		yield(timer, "timeout")

func _reset_moved(node):
	var units = get_node(node).get_children()
	for unit in units:
		unit.moved = false

func _check_moves(node, next_turn):
	var units = get_node(node).get_children()
	var moved_count = 0
	for unit in units:
		if unit.moved:
			moved_count += 1
	if len(units) == moved_count:
		current_turn = next_turn


func get_available_movement_tiles(x: int, y: int, move_range: int, move_pattern):
	var all_tiles = []

	for neigbour in get_neighours(x, y, move_pattern):
		if is_blocked(neigbour.x, neigbour.y):
			continue
		if move_range > 1:
			for sub_neigbour in get_available_movement_tiles(neigbour.x, neigbour.y, move_range-1, move_pattern):
				if !all_tiles.has(sub_neigbour):
					all_tiles.append(sub_neigbour)
		if !all_tiles.has(neigbour):
			all_tiles.append(neigbour)

	if all_tiles.has(Vector2(x, y)):
		all_tiles.remove(all_tiles.find(Vector2(x, y)))

	return all_tiles

func get_neighours(x: int, y: int, pattern):
	match pattern:
		MovementPattern.PATTERN.NORMAL:
			return get_normal_neighbours(x, y)
		MovementPattern.PATTERN.DIAGONAL:
			return get_diagonal_neighbours(x, y)
		MovementPattern.PATTERN.HORSE:
			return get_horse_neighbours(x, y)
		MovementPattern.PATTERN.LEFT_FORWARD:
			return get_left_forward_neighbours(x, y)

func get_normal_neighbours(x: int, y: int):
	return [
		Vector2(x-1, y),
		Vector2(x, y-1),
		Vector2(x, y+1),
		Vector2(x+1, y)
	]

func get_left_forward_neighbours(x: int, y: int):
	return [
		Vector2(x-1, y),
		Vector2(x, y-1)
	]

func get_diagonal_neighbours(x, y):
	return [
		Vector2(x-1, y-1),
		Vector2(x+1, y-1),
		Vector2(x+1, y+1),
		Vector2(x-1, y+1)
	]

func get_horse_neighbours(x, y):
	return [
		Vector2(x-1, y-2),
		Vector2(x-2, y-1),
		Vector2(x-1, y+2),
		Vector2(x-2, y+1),
		Vector2(x+1, y-2),
		Vector2(x+2, y-1),
		Vector2(x+2, y+1),
		Vector2(x+1, y+2),
	]
