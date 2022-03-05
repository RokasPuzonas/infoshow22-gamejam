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
		
func is_blocked(pos: Vector3):
	var cell = $GridMap.get_cell_item(pos.x, pos.y, pos.z);

func get_unit_at(x: int, y: int):
	for unit in $PlayerUnits.get_children():

		if unit.translation.x-0.5 == x && unit.translation.z-0.5 == y:
			return unit

func select_unit(unit):
	selected_unit = unit
	var Marker = load("res://MovementMarker.tscn")
	available_moves = unit.get_move_tiles()
	$MoveMarkers.translation = unit.translation - Vector3(1, -1, -1)
	for tile in available_moves:
		var marker = Marker.instance()
		marker.translation = Vector3(tile.x, 0, tile.y)
		$MoveMarkers.add_child(marker)

func deselect_unit():
	selected_unit = null
	for marker in $MoveMarkers.get_children():
		$MoveMarkers.remove_child(marker)


func _process(delta):
	var pos = get_tile_position();
	if pos != null:
		var unit_on_mouse = get_unit_at(pos.x, pos.z)
		if Input.is_action_just_pressed("mouse_press"):
			if selected_unit == null && unit_on_mouse != null and not unit_on_mouse.enemy and not unit_on_mouse.moved:
				select_unit(unit_on_mouse)
			elif selected_unit != null:
				selected_unit.translation = Vector3(0.5+pos.x, 0.5, 0.5+pos.z)
				selected_unit.moved = true
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
		yield(timer, "timeout")
		unit.translation = Vector3(0.5+unit.translation.x, 0.5, 0.5+unit.translation.z)
		
	
		unit.moved = true
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
	
