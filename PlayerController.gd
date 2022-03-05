extends Node

var selected_unit;
var available_moves;
onready var world = get_parent()

signal end_turn;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func select_unit(unit):
	selected_unit = unit
	var Marker = load("res://MovementMarker.tscn")

	var gridMap = world.get_node("GridMap")
	available_moves = []
	var map_pos = gridMap.world_to_map(unit.translation)
	for tile in world.get_available_movement_tiles(map_pos.x, map_pos.z, unit.movement_range, unit.movement_pattern):
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

func on_turn_enter():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		deselect_unit()
		
	var pos = world.get_tile_position();
	if pos != null:
		var unit_on_mouse = world.get_player_unit_at(pos.x, pos.z)
		if Input.is_action_just_pressed("mouse_press"):
			if selected_unit == null && unit_on_mouse != null and not unit_on_mouse.enemy and not unit_on_mouse.moved:
				select_unit(unit_on_mouse)
			elif selected_unit != null:
				if !move_selected(pos):
					deselect_unit()
