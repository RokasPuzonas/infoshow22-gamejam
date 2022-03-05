extends Spatial

onready var Marker = load("res://CursorMarker.tscn")
var current_marker

var current_turn

signal phase_changed;

func _ready():
	set_phase(TurnPhase.PHASE.PLAYER)

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
			get_enemy_unit_at(x, y) != null || \
			get_player_unit_at(x, y) != null

func get_enemy_unit_at(x: int, y: int):
	for unit in $EnemyUnits.get_children():
		if unit.translation.x-0.5 == x && unit.translation.z-0.5 == y:
			return unit

func get_player_unit_at(x: int, y: int):
	for unit in $PlayerUnits.get_children():
		if unit.translation.x-0.5 == x && unit.translation.z-0.5 == y:
			return unit

func _process(delta):
	var pos = get_tile_position();
	if pos != null:
		show_marker_at(pos.x, pos.z)
	else:
		hide_marker()

	if current_turn == TurnPhase.PHASE.PLAYER && !has_unmoved_units("PlayerUnits"):
		set_phase(TurnPhase.PHASE.ENEMY)

func set_phase(phase):
	if current_turn == phase:
		return
		
	current_turn = phase
	if phase == TurnPhase.PHASE.PLAYER:
		reset_moved_units("PlayerUnits")
		$EnemyController.set_process(false)
		$PlayerController.set_process(true)
		$PlayerController.on_turn_enter()
	elif phase == TurnPhase.PHASE.ENEMY:
		reset_moved_units("EnemyUnits")
		$EnemyController.set_process(true)
		$PlayerController.set_process(false)
		$EnemyController.on_turn_enter()
	emit_signal("phase_changed", phase)
		

func reset_moved_units(node):
	var units = get_node(node).get_children()
	for unit in units:
		unit.moved = false

func has_unmoved_units(node):
	var units = get_node(node).get_children()
	for unit in units:
		if !unit.moved:
			return true
	return false

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
	var offsets = []
	match pattern:
		MovementPattern.PATTERN.DIAGONAL:
			offsets = [
				Vector2(-1, -1), Vector2(+1, -1),
				Vector2(+1, +1), Vector2(-1, +1)
			]
		MovementPattern.PATTERN.HORSE:
			offsets = [
				Vector2(-1, y-2), Vector2(-2, -1),
				Vector2(-1, y+2), Vector2(-2, +1),
				Vector2(+1, y-2), Vector2(+2, -1),
				Vector2(+2, y+1), Vector2(+1, +2),
			]
		MovementPattern.PATTERN.LEFT_FORWARD:
			offsets = [
				Vector2(-1, 0), Vector2(0, -1)
			]
		_: # aka, MovementPattern.PATTERN.NORMAL
			offsets = [
				Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)
			]
	
	var positions = []
	for offset in offsets:
		positions.push_back(Vector2(x, y) + offset)
	return positions


func _on_EndTurnButton_pressed():
	set_phase(TurnPhase.PHASE.ENEMY)

func _on_PlayerController_end_turn():
	set_phase(TurnPhase.PHASE.ENEMY)

func _on_EnemyController_end_turn():
	set_phase(TurnPhase.PHASE.PLAYER)
