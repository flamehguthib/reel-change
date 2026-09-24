extends Control

signal finished(caught: bool)

#bar
var bar_pos = 0.0
var bar_velocity = 0.0
var bar_size = 100.0
const GRAVITY = 460
var lift_force = -1080

#fish
var fish_pos = 200.0
var fish_target = 200.0
var fish_timer = 0.0
@onready var fish_height = %Fish_icon.size.y

#difficulty (set by the fisherman based on the caught species)
var speed_multiplier := 1.0
var grace_time_multiplier := 1.0

#progress
var progress = 52.0
var max_height = 200
var grace_time = 0.35

func _ready() -> void:
	bar_size = %PlayerBar.size.y

func set_difficulty(speed: float, grace: float) -> void:
	speed_multiplier = speed
	grace_time_multiplier = grace
	grace_time = 0.35 * grace

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("space"):
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
		fish_timer = randf_range(0.5, 1.5) * (1.0 / speed_multiplier)
		fish_timer = max(fish_timer, 0.2)
		
	fish_pos = lerp(fish_pos, fish_target, delta * 3.6 * speed_multiplier)

	if grace_time > 0.0:
		grace_time = max(grace_time - delta, 0.0)
	else:
		if fish_pos >= bar_pos and fish_pos <= (bar_pos + bar_size):
			progress += delta * 30
		else:
			progress += delta * -15
		
	progress = clamp(progress, 0, 100)
	
	%PlayerBar.position.y = bar_pos
	%Fish_icon.position.y = fish_pos
	%ProgressBar.value = progress

	# Visual Tension Polish
	if progress < 25.0:
		# Red danger flash when about to lose line
		var flash := sin(Time.get_ticks_msec() * 0.015) * 0.5 + 0.5
		%PlayerBar.color = Color(1.0, 0.2 * flash, 0.2 * flash, 0.8)
	elif progress < 55.0:
		# Orange warning tension
		%PlayerBar.color = Color(1.0, 0.65, 0.1, 0.7)
	else:
		# Green/Cyan safe tension
		%PlayerBar.color = Color(0.1, 0.85, 0.4, 0.75)

	check_win_loss()
	
func check_win_loss():
	if progress >= 100:
		print("Fish Caught!")
		emit_signal("finished", true)
		queue_free()
	elif progress <= 0:
		print("Fish Escaped!")
		emit_signal("finished", false)
		queue_free()
