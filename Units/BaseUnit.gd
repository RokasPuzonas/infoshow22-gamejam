extends Spatial

export var max_health = 100
export var attack = 10
export var movement_range = 3
export var movement_pattern = MovementPattern.PATTERN.NORMAL
export var enemy = false
export var moved = false

var stage = 0;

export(Texture) var stage0_texture;
export(Texture) var stage1_texture;
export(Texture) var stage2_texture;

var health = 0

func _ready():
	health = max_health
	$MeshInstance.material_override = SpatialMaterial.new()
	$MeshInstance.material_override.flags_transparent = true
	$MeshInstance.material_override.flags_unshaded = true
	
	update_stage_sprite();

func update_stage_sprite():
	if stage == 0:
		$MeshInstance.material_override.albedo_texture = stage0_texture
	elif stage == 1:
		$MeshInstance.material_override.albedo_texture = stage1_texture
	else:
		$MeshInstance.material_override.albedo_texture = stage2_texture

func next_stage():
	stage = max(stage+1, 2)
	update_stage_sprite()

func apply_mutation(mutation):
	if mutation.max_health_modifier != 0:
		max_health *= (1 + mutation.max_health_modifier)
		if mutation.max_health_modifier > 0:
			health = max_health
	
	attack *= (1+mutation.attack_modifier)
	movement_range += mutation.range_modifier
	
	if mutation.apply_pattern:
		movement_pattern = mutation.override_pattern

func get_move_tiles():
	return get_available_movement_tiles(0, 0, movement_range, movement_pattern)

func get_available_movement_tiles(x: int, y: int, move_range: int, move_pattern):
	var all_tiles = []
	
	for neigbour in get_neighours(x, y, move_pattern):
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
