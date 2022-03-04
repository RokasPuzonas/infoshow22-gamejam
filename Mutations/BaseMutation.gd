
export(String) var mutation_name;
export(String, MULTILINE) var description;
export(float, -1, 1, 0.05) var max_health_modifier = 0;
export(float, -1, 1, 0.05) var attack_modifier = 0;
export(int) var range_modifier = 0;
export(bool) var apply_pattern = false;
export(MovementPattern.PATTERN) var override_pattern = null;

