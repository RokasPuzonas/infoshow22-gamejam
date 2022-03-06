extends Node

var selected_unit;
var available_moves;

onready var MoveMarker = load("res://MovementMarker.tscn")
onready var UnmovedMarker = load("res://UnmovedMarker.tscn") 
onready var level = get_parent()

func _ready():
	available_moves = []

func select_unit(unit: Node):
	selected_unit = unit
	
	available_moves = level.get_available_moves(selected_unit)
	for move in available_moves:
		var marker = MoveMarker.instance()
		marker.translation = move
		$MoveMarkers.add_child(marker)

func deselect_unit():
	selected_unit = null
	for marker in $MoveMarkers.get_children():
		$MoveMarkers.remove_child(marker)

func move_selected(target_pos: Vector3):
	if !available_moves.has(target_pos):
		return
	
	level.world.move_unit(selected_unit.translation, target_pos)
	selected_unit.get_node("UnmovedMarker").queue_free()
	#selected_unit.get_node("StepSoundPlayer").play()

func _process(_delta):
	if selected_unit != null && Input.is_action_just_pressed("ui_cancel"):
		deselect_unit()
	
	#print(level.get_position_under_mouse(), " ", level.get_unit_under_mouse())
	if Input.is_action_just_pressed("mouse_press"):
		var mouse_pos = level.get_position_under_mouse()
		var unit_on_mouse = level.get_unit_under_mouse()
		if mouse_pos != null:
			if selected_unit == null && \
				 unit_on_mouse != null && \
				 not unit_on_mouse.enemy && \
				 not unit_on_mouse.moved:
				select_unit(unit_on_mouse)
			elif selected_unit != null:
				move_selected(mouse_pos)
				deselect_unit()

func _on_BaseLevel_player_phase_enter():
	for unit in level.get_player_units():
		unit.add_child(UnmovedMarker.instance())
		
func _on_BaseLevel_player_phase_leave():
	for unit in level.get_player_units():
		var marker = unit.find_node("UnmovedMarker")
		if marker != null:
			marker.queue_free()
