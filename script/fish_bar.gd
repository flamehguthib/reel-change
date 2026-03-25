extends Control

#bar
var bar_pos = 0.0
var bar_velocity = 0.0
var bar_size = 100.0
const GRAVITY = 400
var lift_force = -1200

#fish
var fish_pos = 200.0
var fish_target = 200.0
var fish_timer = 0.0
@onready var fish_height = %Fish_icon.size.y

#progress
var progress = 50.0
var max_height = 200

func _ready() -> void:
	bar_size = %PlayerBar.size.y

func _physics_process(delta: float) -> void:
	queue_redraw()
	if Input.is_action_pressed("jump"):
		bar_velocity += delta * lift_force
	
	bar_velocity += delta * GRAVITY
	bar_pos += delta * bar_velocity
	
	bar_pos = clamp(bar_pos, 0, max_height - bar_size)
	if bar_pos == 0 or bar_pos == max_height - bar_size:
		bar_velocity = 0
		
	fish_timer -= delta
	if fish_timer <= 0:
		var min_y = 10
		var max_y = max_height - fish_height - 10
		fish_target = randf_range(min_y, max_y)
		fish_timer = randf_range(2.0, 4.0)
		
	fish_pos = lerp(fish_pos, fish_target, delta * 3.0)
	
	if fish_pos >= bar_pos and fish_pos <= (bar_pos + bar_size):
		progress += delta * 20 
	else: 
		progress += delta * -10
		
	progress = clamp(progress, 0, 100)
	
	%PlayerBar.position.y = bar_pos
	%Fish_icon.position.y = fish_pos
	%ProgressBar.value = progress
	
	check_win_loss()
	
func check_win_loss():
	if progress >= 100:
		print("Fish Caught!")
		set_physics_process(false)
	elif progress <= 0:
		print("Fish Escaped!")
		set_physics_process(false)
		
func _draw():
	# Draw a red line at the calculated bottom of the bar
	# We use (0, bar_pos + bar_size) as the starting point
	var bottom_y = bar_pos + bar_size
	draw_line(Vector2(0, bottom_y), Vector2(100, bottom_y), Color.RED, 2.0)
