extends CharacterBody2D

var movement_speed = 67
const gravity = 980
var jump_force = -200
var state = "idle"

func _ready() -> void:
	$Sprite2D.connect("animation_finished", Callable(self, "on_casting_finished"))

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
	
	#animation
	if state == "fish" and Input.is_action_just_pressed("fish_button"):
		$Sprite2D.play("hook")
		state = "idle"
		
	elif state != "cast" and Input.is_action_just_pressed("fish_button"):
		$Sprite2D.play("cast")
		state = "cast"
		fish()
		
	elif state != "cast" and state != "fish":	
		if velocity.x == 0:
			if state != "idle":
				$Sprite2D.play("idle")
				state = "idle"
		elif velocity.x != 0:
			if state != "walk":
				$Sprite2D.play("walk")
				state = "walk"
				
	movement()
	
func movement():
	velocity.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	velocity.x *= movement_speed
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	move_and_slide()
	
func fish():
	pass

func on_casting_finished():
	if $Sprite2D.animation == "cast":
		$Sprite2D.play("fish")
		state = "fish"
		
	if $Sprite2D.animation == "fish":
		$Sprite2D.play("idle")
		state = "idle"
			
				
				
