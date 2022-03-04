extends KinematicBody2D

var speed = 100
var gravity = 10

var input = Vector2.ZERO
var facing_direction = 1
var velocity = Vector2.ZERO

var jump_force = -200
var jump_start_time = 0
var jump_hold_delay = 100
var jump_count = 2
var pressed_jump = false
var released_jump = false

onready var main_sprite = $MainSprite

func _ready():
	pass 
	
func _check_jump():
	if Input.is_action_just_pressed("jump"):
		pressed_jump = true
		jump_start_time = OS.get_ticks_msec()
		
	if Input.is_action_just_released("jump") and velocity.y < jump_force / 2:
		velocity.y = jump_force / 2
		
	if is_on_floor():
		jump_count = 2
		
	if pressed_jump:
		if is_on_floor():
			velocity.y = jump_force
			pressed_jump = false
		else:
			if jump_count >= 1:
				velocity.y = jump_force
				jump_count -= 1
		if OS.get_ticks_msec() >= jump_start_time + jump_hold_delay:
			
			pressed_jump = false
		else:
			if is_on_floor():
				velocity.y = jump_force
				pressed_jump = false
		
		
		
func _physics_process(delta):
	print(jump_start_time, " ", OS.get_ticks_msec())
	
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if input.x != 0:
		velocity.x = input.x * speed
	else:
		velocity.x = 0
	if is_on_floor():
		velocity.y = gravity
	velocity.y += gravity
	_check_jump()
	velocity = move_and_slide(velocity, Vector2.UP)
	

#func _process(delta):
#	pass
