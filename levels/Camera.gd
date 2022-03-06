extends Camera

export var decay = 0.9  # How quickly the shaking stops [0, 1].
export var max_offset = Vector3(0.05, 0.05, 0.05)  # Maximum hor/ver shake in pixels.

var offset
var original_translation
var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].

func _ready():
	randomize()
	original_translation = translation
	offset = Vector3()

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func _process(delta):
	translation = original_translation + offset

	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func shake():
	var amount = pow(trauma, trauma_power)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)
	offset.z = max_offset.z * amount * rand_range(-1, 1)
