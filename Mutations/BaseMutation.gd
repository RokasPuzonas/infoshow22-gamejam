extends Control

export(String) var mutation_name;
export(String, MULTILINE) var description;
export(float, -1, 1, 0.05) var max_health_modifier = 0;
export(float, -1, 1, 0.05) var attack_modifier = 0;
export(int) var range_modifier = 0;
export(bool) var apply_pattern = false;
export(MovementPattern.PATTERN) var override_pattern = null;

signal apply_pressed;

func _ready():
	$Container/Description.text = description;
	$Container/Name.text = mutation_name;

func _on_ApplyButton_pressed():
	emit_signal("apply_pressed", self)
