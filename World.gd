extends Spatial

onready var Marker = load("res://CursorMarker.tscn")
onready var Dialog = load("res://Dialog.tscn")
var current_dialog
var current_marker

var current_turn

signal phase_changed;

func _ready():
	get_tree().paused = false
	
	set_phase(TurnPhase.PHASE.PLAYER)
	if get_parent().name == "Level1":
		play_dialog("res://assets/Dialog/DialogTutorial.json")
	


func play_dialog(path):
	
	current_dialog = Dialog.instance()
	current_dialog.dialogPath = path
	add_child(current_dialog)

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
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene("res://LoseScreen.tscn")

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
	elif phase == TurnPhase.PHASE.COMBAT:
		$EnemyController.set_process(false)
		$PlayerController.set_process(false)
		perform_combat()
	emit_signal("phase_changed", phase)

func perform_combat():
	var player_units = $PlayerUnits.get_children() 
	var enemy_units = $EnemyUnits.get_children()
	
	for player_unit in player_units:
		for nearby_unit in get_units_around(player_unit, enemy_units):
			perform_attack(player_unit, nearby_unit)
			yield(get_tree().create_timer(0.5), "timeout")
			if nearby_unit.health <= 0:
				enemy_units.remove(enemy_units.find(nearby_unit))
				nearby_unit.queue_free()
	
	for enemy_unit in enemy_units:
		for nearby_unit in get_units_around(enemy_unit, player_units):
			perform_attack(enemy_unit, nearby_unit)
			yield(get_tree().create_timer(0.5), "timeout")
			if nearby_unit.health <= 0:
				player_units.remove(player_units.find(nearby_unit))
				nearby_unit.queue_free()
	
	set_phase(TurnPhase.PHASE.PLAYER)
	
func perform_attack(from, to):
	to.emit_damage_particles()
	to.take_damage(from.attack)

func get_units_around(target, possible_units):
	var close_units = []
	for possible_unit in possible_units:
		if has_node(possible_unit.get_path()) && target.translation.distance_to(possible_unit.translation) <= 1:
			close_units.push_back(possible_unit)
	return close_units

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
	if current_turn == TurnPhase.PHASE.PLAYER:
		set_phase(TurnPhase.PHASE.ENEMY)

func _on_PlayerController_end_turn():
	set_phase(TurnPhase.PHASE.ENEMY)

func _on_EnemyController_end_turn():
	set_phase(TurnPhase.PHASE.COMBAT)
