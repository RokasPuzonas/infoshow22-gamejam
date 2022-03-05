extends Camera



var mouse_pos: Vector2

signal cell_pressed

func get_cell_pos():
	mouse_pos = get_viewport().get_mouse_position()
	var space_state = get_world().direct_space_state
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * 10000
	var cursorPos = space_state.intersect_ray(from, to)
	return cursorPos.get("position")
func _physics_process(delta):
	if Input.is_action_just_pressed("mouse_press"):
		emit_signal("cell_pressed", get_cell_pos())
	


