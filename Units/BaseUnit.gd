extends Spatial

export var max_health = 100
export var attack = 10
export var movement_range = 3
export(MovementPattern.PATTERN) var movement_pattern = MovementPattern.PATTERN.NORMAL
export var enemy = false
export var stage = 0

var full_health_color = Color("e90000")
var no_health_color = Color("1c1c1c")
var moved = false 


export(Array, Texture) var stage_textures;

var health = 0

func _ready():
	$Sprite.material_override = SpatialMaterial.new()
	$Sprite.material_override.flags_transparent = true
	$Sprite.material_override.flags_unshaded = true
	
	$Healthbar.material_override = SpatialMaterial.new()
	$Healthbar.material_override.flags_transparent = true
	$Healthbar.material_override.flags_unshaded = true
	
	health = max_health
	take_damage(0) # Scuff, line. Just so that it sets the right color
	
	update_stage_sprite();

func update_stage_sprite():
	$Sprite.material_override.albedo_texture = stage_textures[min(stage, get_max_stages()-1)]

func get_max_stages():
	return len(stage_textures)


func apply_mutation(mutation):
	if mutation.max_health_modifier != 0:
		max_health *= (1 + mutation.max_health_modifier)
		if mutation.max_health_modifier > 0:
			health = max_health # Full heal, when mutating
			take_damage(0) # Scuffed color update
	
	attack *= (1+mutation.attack_modifier)
	movement_range += mutation.range_modifier
	
	if mutation.apply_pattern:
		movement_pattern = mutation.override_pattern
	
	
	stage = min(stage+1, get_max_stages()-1)
	update_stage_sprite()
	
	return true

func take_damage(damage):
	health -= damage
	
	var progress = float(health)/max_health
	var health_color = no_health_color.linear_interpolate(full_health_color, progress)
	$Healthbar.material_override.albedo_color = health_color
	
	if damage > 0:
		$AudioStreamPlayer.play()

func emit_damage_particles():
	$DamageParticles.emitting = true
