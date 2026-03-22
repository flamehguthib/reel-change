extends CharacterBody2D

var movement_speed = 67
const gravity = 980
var jump_force = -200

func _physics_process(delta):
	#gravity typa shi
	if not is_on_floor():
		velocity.y += gravity * delta
		move_and_slide()
		
	#invert
	if velocity.x < 0:
		$Sprite2D.flip_h = true
	elif velocity.x > 0: 
		$Sprite2D.flip_h = false 
	
	#fish
	if Input.is_action_just_pressed("fish_button"):
		$Sprite2D.play("cast")
		fish()
	
	
	#animation
	if velocity.x == 0:
		$Sprite2D.play("idle")
	else:
		$Sprite2D.play("walk")
		
	movement()
	
func movement():
	velocity.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	velocity.x *= movement_speed
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	move_and_slide()
	
func fish():
	pass
