extends Spatial

enum MOVEMENT_PATTERN {
	NORMAL,
	DIAGONAL
}

export var max_health = 100
export var attack = 10
export var movement_range = 3
export var movement_pattern = MOVEMENT_PATTERN.NORMAL

var health = 0

func _ready():
	health = max_health

func get_available_movement_tiles(x: int, y: int, move_range: int, move_pattern):
	var all_tiles = []
	
	return all_tiles

func get_neighours(x: int, y: int, pattern):
	match pattern {
		case NORMAL:
			return []
	}

func get_normal_neighbours(x: int, y: int):
	return [
		Vector2(x-1, y),
		Vector2(x, y-1),
		Vector2(x, y+1),
		Vector2(x+1, y)
	]

func get_diagonal_neighbours(x, y):
	pass
