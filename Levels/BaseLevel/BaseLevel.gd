extends Spatial

export(int) var turn_limit = 5
export var do_mutation = true
export(int) var mutation_frequency = 2
export(PackedScene) var next_scene

onready var world = $World
onready var dialogSystem = get_tree().get_root().get_node("/root/DialogSystem")
onready var transitionSystem = get_tree().get_root().get_node("/root/TransitionSystem")

signal player_phase_enter
signal enemy_phase_enter
signal player_phase_leave
signal enemy_phase_leave

onready var CursorMarker = load("res://Markers/CursorMarker.tscn")

var force_stay_on_scene = false
var current_phase
var current_turn = 0
var selected_mutation
var cursor_marker

func _ready():
	$PlayerController.set_process(false)
	$EnemyController.set_process(false)
	current_phase = TurnPhase.PHASE.MUTATION
	next_phase()

func _on_mutation_enter():
	pass

func next_phase():
	match current_phase:
		TurnPhase.PHASE.PLAYER:
			emit_signal("player_phase_leave")
			$"UI/EndTurn".visible = false
			current_phase = TurnPhase.PHASE.ENEMY
		TurnPhase.PHASE.ENEMY:
			emit_signal("enemy_phase_leave")
			current_phase = TurnPhase.PHASE.COMBAT
		TurnPhase.PHASE.COMBAT:
			if current_turn % mutation_frequency == 0 && do_mutation:
				current_phase = TurnPhase.PHASE.MUTATION
			else:
				current_phase = TurnPhase.PHASE.PLAYER
			current_turn += 1
		TurnPhase.PHASE.MUTATION:
			$"UI/PickUnitLabel".visible = false
			selected_mutation = null
			current_phase = TurnPhase.PHASE.PLAYER
	
	match current_phase:
		TurnPhase.PHASE.PLAYER:
			$"UI/PhaseLabel".text = "Your turn"
			reset_moved_units()
			$"UI/EndTurn".visible = true
			$PlayerController.set_process(true)
			$EnemyController.set_process(false)
			emit_signal("player_phase_enter")
		TurnPhase.PHASE.ENEMY:
			$"UI/PhaseLabel".text = "Enemy turn"
			$EnemyController.set_process(true)
			$PlayerController.set_process(false)
			emit_signal("enemy_phase_enter")
		TurnPhase.PHASE.COMBAT:
			$"UI/PhaseLabel".text = "En garde! Combat!"
			$EnemyController.set_process(false)
			$PlayerController.set_process(false)
			perform_combat()
		TurnPhase.PHASE.MUTATION:
			_on_mutation_enter()
			$"UI/PhaseLabel".text = ""
			$"UI/MutationPicker".show_picker()

func set_cursor_marker(pos: Vector3):
	if cursor_marker == null:
		cursor_marker = CursorMarker.instance()
		add_child(cursor_marker)
	cursor_marker.translation = pos + Vector3(0.5, 0.5 + 0.05, 0.5)

func clear_cursor_marker():
	if cursor_marker != null:
		cursor_marker.queue_free()
		cursor_marker = null

func _process(_delta):
	if (len(get_enemy_units()) == 0 && !force_stay_on_scene) || Input.is_action_just_pressed("debug_skip_level"):
		transitionSystem.change_scene_to(next_scene)
	elif len(get_player_units()) == 0 || Input.is_action_just_pressed("debug_game_over"):
		transitionSystem.change_scene("res://UI/LoseScreen.tscn")
		
	var pos = get_position_under_mouse()
	if pos:
		set_cursor_marker(pos)
	else:
		clear_cursor_marker()
	
	if Input.is_action_just_pressed("mouse_press"):
		if current_phase == TurnPhase.PHASE.MUTATION && selected_mutation != null:
			var unit_on_mouse = get_unit_under_mouse()
			if unit_on_mouse != null and not unit_on_mouse.enemy:
				if unit_on_mouse.apply_mutation(selected_mutation):
					selected_mutation = null
					next_phase()
	
	if current_phase == TurnPhase.PHASE.PLAYER && has_player_moved_all():
		next_phase()

func perform_combat():
	var player_units = get_player_units()
	var enemy_units = get_enemy_units()
	
	for player_unit in player_units:
		for nearby_unit in get_units_around(player_unit, enemy_units):
			perform_attack(player_unit, nearby_unit)
			yield(get_tree().create_timer(0.5), "timeout")
	
	for enemy_unit in enemy_units:
		for nearby_unit in get_units_around(enemy_unit, player_units):
			perform_attack(enemy_unit, nearby_unit)
			yield(get_tree().create_timer(0.5), "timeout")
	
	for unit in world.get_all_units():
		if unit.health <= 0:
			world.free_unit_at(unit.translation)
	
	next_phase()
	
func perform_attack(from, to):
	to.emit_damage_particles()
	to.take_damage(from.attack)
	$Camera.add_trauma(1)

func get_units_around(target, possible_units):
	var close_units = []
	for possible_unit in possible_units:
		if has_node(possible_unit.get_path()) && target.translation.distance_to(possible_unit.translation) <= 1:
			close_units.push_back(possible_unit)
	return close_units

func reset_moved_units():
	for unit in world.get_all_units():
		unit.moved = false

func get_position_under_mouse() -> Vector3:
	return $World.get_position_under_mouse($Camera)

func get_unit_under_mouse() -> Spatial:
	return $World.get_unit_under_mouse($Camera)

func get_available_moves(unit: Spatial) -> Array:
	var pos = $World.world_to_map(unit.translation)
	return get_available_movement_tiles(pos, unit.movement_range, unit.movement_pattern)

func get_enemy_units() -> Array:
	var enemy_units = []
	for unit in $World.get_all_units():
		if unit.enemy:
			enemy_units.push_back(unit)
	return enemy_units

func get_player_units() -> Array:
	var player_units = []
	for unit in $World.get_all_units():
		if !unit.enemy:
			player_units.push_back(unit)
	return player_units

func has_player_moved_all() -> bool:
	for unit in $World.get_all_units():
		if !unit.enemy && !unit.moved:
			return false
	return true

func get_available_movement_tiles(from: Vector3, move_range: int, move_pattern):
	var all_tiles = []
	
	for neigbour in get_movement_neighours(from, move_pattern):
		if !$World.is_spot_walkable(neigbour):
			continue
		if move_range > 1:
			for sub_neigbour in get_available_movement_tiles(neigbour, move_range-1, move_pattern):
				if !all_tiles.has(sub_neigbour):
					all_tiles.append(sub_neigbour)
		if !all_tiles.has(neigbour):
			all_tiles.append(neigbour)

	if all_tiles.has(from):
		all_tiles.remove(all_tiles.find(from))

	return all_tiles

func get_movement_neighours(from: Vector3, pattern):
	var offsets = []
	match pattern:
		MovementPattern.PATTERN.DIAGONAL:
			offsets = [
				Vector2(-1, -1), Vector2(+1, -1),
				Vector2(+1, +1), Vector2(-1, +1)
			]
		MovementPattern.PATTERN.HORSE:
			offsets = [
				Vector2(-1, -2), Vector2(-2, -1),
				Vector2(-1, +2), Vector2(-2, +1),
				Vector2(+1, -2), Vector2(+2, -1),
				Vector2(+2, +1), Vector2(+1, +2),
			]
		MovementPattern.PATTERN.LEFT_FORWARD:
			offsets = [
				Vector2(1, 0), Vector2(0, -1)
			]
		MovementPattern.PATTERN.EXTENED_NORMAL:
			offsets = [
				Vector2(2, 0), Vector2(-2, 0), Vector2(0, 2), Vector2(0, -2)
			]
		_: # aka, MovementPattern.PATTERN.NORMAL
			offsets = [
				Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)
			]
	
	var positions = []
	for offset in offsets:
		positions.push_back(from + Vector3(offset.x, 0, offset.y))
	return positions


func _on_EnemyController_finished_turn():
	next_phase()

func _on_MutationPicker_picked_mutation(mutation):
	$"UI/PickUnitLabel".visible = true
	selected_mutation = mutation

func _on_EndTurn_pressed():
	next_phase()
