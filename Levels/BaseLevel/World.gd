extends Spatial

var units

func _ready():
	units = {}
	
	for unit in get_children():
		if unit == $GridMap:
			continue
		var pos = $GridMap.world_to_map(unit.translation)
		var key = "%d;%d" % [int(pos.x), int(pos.z)]
		units[key] = unit

func get_unit_at(pos: Vector3) -> Node:
	var key = "%d;%d" % [int(pos.x), int(pos.z)]
	if units.has(key):
		return units[key]
	else:
		return null

func add_unit_at(unit: Spatial, pos: Vector3):
	var key = "%d;%d" % [int(pos.x), int(pos.z)]
	if units.has(key):
		return false
	units[key] = unit
	unit.translation = Vector3(int(pos.x), int(pos.y), int(pos.z))
	return true
	
func free_unit_at(pos: Vector3):
	var key = "%d;%d" % [int(pos.x), int(pos.z)]
	if !units.has(key):
		return false
	units[key].queue_free()
	units.erase(key)
	
func remove_unit_at(pos: Vector3):
	var key = "%d;%d" % [int(pos.x), int(pos.z)]
	if !units.has(key):
		return false
	units.erase(key)
	return true

func move_unit(from: Vector3, to: Vector3):
	var unit = get_unit_at(from)
	if unit:
		units.erase("%d;%d" % [int(from.x), int(from.z)])
		unit.translation = Vector3(int(to.x), int(to.y), int(to.z))
		unit.moved = true
		units["%d;%d" % [int(to.x), int(to.z)]] = unit

func get_unit_under_mouse(camera: Camera):
	var pos = get_position_under_mouse(camera)
	if pos != null:
		return get_unit_at(pos)

func get_all_units() -> Array:
	return units.values()

func is_spot_walkable(target: Vector3):
	return $GridMap.get_cell_item(target.x, 0, target.z) != -1 && \
			$GridMap.get_cell_item(target.x, 1, target.z) != 3 && \
			$GridMap.get_cell_item(target.x, 1, target.z) != 6 && \
			get_unit_at(target) == null

func world_to_map(pos: Vector3) -> Vector3:
	return $GridMap.world_to_map(pos)

func get_position_under_mouse(camera: Camera):
	var mouse_pos = get_viewport().get_mouse_position()
	var space_state = get_world().direct_space_state
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 10000
	
	var cursorPos = space_state.intersect_ray(from, to)
	if cursorPos.has("position"):
		return $GridMap.world_to_map(cursorPos["position"])

