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
	if stage == 2:
		return true
	
	stage += 1
	
	if mutation.max_health_modifier != 0:
		max_health *= (1 + mutation.max_health_modifier)
		if mutation.max_health_modifier > 0:
			health = max_health
	
	attack *= (1+mutation.attack_modifier)
	movement_range += mutation.range_modifier
	
	if mutation.apply_pattern:
		movement_pattern = mutation.override_pattern
	
	return true
