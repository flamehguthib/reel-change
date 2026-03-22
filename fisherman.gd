extends CharacterBody2D

var movement_speed = 67
const gravity = 9800
var jump_force = -670

func _physics_process(delta):
	#gravity typa shi
	if not is_on_floor():
		velocity.y += gravity * delta
		move_and_slide()
		
	movement()
	
func movement():
	velocity.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var jump = Input.get_action_strength("up")
	velocity.x *= movement_speed
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	move_and_slide()
