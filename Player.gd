extends KinematicBody2D

var speed = 100
var gravity = 100

var input = Vector2.ZERO
var facing_direction = 1
var velocity = Vector2.ZERO

var jump_force = -200
var pressed_jump = false

onready var main_sprite = $MainSprite

func _ready():
	pass 
	
func _check_jump():
	pressed_jump = Input.is_action_just_pressed("jump")
	
	if pressed_jump:
		velocity.y = jump_force
		
func _physics_process(delta):
	#velocity.y += gravity
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if input.x != 0:
		velocity.x = input.x * speed
	else:
		velocity.x = 0
		
	velocity = move_and_slide(velocity, Vector2.UP)

#func _process(delta):
#	pass
