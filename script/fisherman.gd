extends CharacterBody2D

#this fucking bobber
var bobber_global_pos : Vector2 = Vector2.ZERO

var movement_speed = 67
const GRAVITY = 980
var state = "idle"

const CAST_IDLE = 0
const CAST_THROWING = 1
const CAST_WAITING = 2
const CAST_RETRACTING = 3

var cast_visual_state = CAST_IDLE
var cast_distance = 0.0
var cast_direction = 1
var cast_target_distance = 130.0
var min_cast_distance = 45.0
var max_cast_distance = 190.0
var cast_speed = 280.0
var reel_speed = 420.0
var cast_origin_offset = Vector2(8, -8)
var cast_water_y_offset = 92.0
var arc_peak_height = 46.0
var min_arc_peak_height = 28.0
var max_arc_peak_height = 62.0
var is_charging_cast = false
var charge_time = 0.0
var max_charge_time = 0.9
var power_bar_offset = Vector2(-26, -48)
var power_bar_size = Vector2(52, 6)
var actual_cast_distance = 0.0  # Distance where the line actually hits something

func _ready() -> void:
	$Sprite2D.connect("animation_finished", Callable(self, "on_casting_finished"))

func _physics_process(delta):
	#gravity typa shi
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		move_and_slide()
	
	if state == "hook":
		kill_fishing_bob()
	
	#invert
	if velocity.x < 0:
		$Sprite2D.flip_h = true
	elif velocity.x > 0: 
		$Sprite2D.flip_h = false 
	
	#animation
	if state == "fish" and Input.is_action_just_pressed("fish_button"):
		$Sprite2D.play("hook")
		state = "hook"
		start_reel()
	
	# Retract cast when moving
	elif state == "fish" and velocity.x != 0:
		$Sprite2D.play("hook")
		state = "hook"
		start_reel()
		
	elif can_start_charge() and Input.is_action_just_pressed("fish_button"):
		begin_charge_cast()

	elif state == "charge":
		if Input.is_action_pressed("fish_button"):
			update_charge(delta)
		elif Input.is_action_just_released("fish_button"):
			release_charge_cast()
		
	elif state != "cast" and state != "fish" and state != "hook" and state != "charge":	
		if velocity.x == 0:
			if state != "idle":
				$Sprite2D.play("idle")
				state = "idle"
		elif velocity.x != 0:
			if state != "walk":
				$Sprite2D.play("walk")
				state = "walk"
				
	update_cast_visual(delta)
	movement()
	
func movement():
	velocity.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	velocity.x *= movement_speed
	
	move_and_slide()

func can_start_charge():
	return state != "cast" and state != "fish" and state != "hook"

func calculate_cast_collision() -> float:
	var start = get_cast_start_offset()
	# Cast downward and outward based on cast direction
	var target_horizontal = start + Vector2(cast_direction * max_cast_distance, 0)
	var end_position = target_horizontal + Vector2(0, cast_water_y_offset)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(start, end_position)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result:
		# Calculate distance to hit point
		var hit_pos = result.position
		# Calculate the horizontal distance traveled before hitting
		var horizontal_distance = abs(hit_pos.x - start.x)
		return clamp(horizontal_distance, min_cast_distance, max_cast_distance)
	else:
		# No collision found, use the charged cast distance
		return cast_target_distance

func begin_charge_cast():
	is_charging_cast = true
	charge_time = 0.0
	state = "charge"
	if $Sprite2D.animation != "idle":
		$Sprite2D.play("idle")
	queue_redraw()

func update_charge(delta):
	charge_time = min(charge_time + delta, max_charge_time)
	queue_redraw()

func release_charge_cast():
	is_charging_cast = false
	var charge_ratio = get_charge_ratio()
	cast_target_distance = lerp(min_cast_distance, max_cast_distance, charge_ratio)
	arc_peak_height = lerp(min_arc_peak_height, max_arc_peak_height, charge_ratio)
	$Sprite2D.play("cast")
	state = "cast"
	start_cast()
	queue_redraw()

func get_charge_ratio():
	if max_charge_time <= 0.0:
		return 1.0
	return clamp(charge_time / max_charge_time, 0.0, 1.0)
	
func start_cast():
	cast_visual_state = CAST_THROWING
	cast_distance = 0.0
	cast_direction = -1 if $Sprite2D.flip_h else 1
	actual_cast_distance = calculate_cast_collision()
	queue_redraw()
	

func start_reel():
	if cast_visual_state != CAST_IDLE:
		cast_visual_state = CAST_RETRACTING

func update_cast_visual(delta):
	if cast_visual_state == CAST_IDLE:
		return

	if cast_visual_state == CAST_THROWING:
		cast_distance = move_toward(cast_distance, actual_cast_distance, cast_speed * delta)
		if is_equal_approx(cast_distance, actual_cast_distance):
			cast_visual_state = CAST_WAITING
	elif cast_visual_state == CAST_RETRACTING:
		cast_distance = move_toward(cast_distance, 0.0, reel_speed * delta)
		if is_zero_approx(cast_distance):
			cast_visual_state = CAST_IDLE

	queue_redraw()

func get_cast_end_offset():
	var target_distance = max(cast_target_distance, 1.0)
	var t = clamp(cast_distance / target_distance, 0.0, 1.0)
	var arc_y = -4.0 * arc_peak_height * t * (1.0 - t)
	return Vector2(cast_distance * cast_direction, cast_water_y_offset + arc_y)

func get_cast_start_offset():
	if not has_node("Sprite2D"):
		return cast_origin_offset

	var sprite = $Sprite2D
	var facing = -1.0 if sprite.flip_h else 1.0
	var sx = abs(sprite.scale.x)
	var sy = abs(sprite.scale.y)

	var hand_offset = Vector2(10.0 * sx * facing, -3.0 * sy)
	var anim_name = String(sprite.animation)

	if anim_name == "cast":
		hand_offset += Vector2(3.0 * sx * facing, -2.0 * sy)
	elif anim_name == "hook":
		hand_offset += Vector2(2.0 * sx * facing, -1.0 * sy)
	elif anim_name == "fish":
		hand_offset += Vector2(1.5 * sx * facing, -0.5 * sy)

	
	hand_offset.y += (float(sprite.frame) - 2.0) * 0.4

	return sprite.position + hand_offset

func get_line_curve_points(start: Vector2, end: Vector2):
	var segments = 16
	var amplitude = 0.0
	if cast_visual_state == CAST_THROWING:
		
		amplitude = -(14.0 + arc_peak_height * 0.3)
	elif cast_visual_state == CAST_WAITING:
		
		amplitude = 18.0
	elif cast_visual_state == CAST_RETRACTING:
		amplitude = 10.0

	var points = PackedVector2Array()
	for i in range(segments + 1):
		var t = float(i) / float(segments)
		var point = start.lerp(end, t)
		point.y += sin(PI * t) * amplitude
		points.append(point)

	return points

func _draw():
	if is_charging_cast:
		var ratio = get_charge_ratio()
		draw_rect(Rect2(power_bar_offset, power_bar_size), Color(0.08, 0.08, 0.08, 0.9), true)
		draw_rect(Rect2(power_bar_offset + Vector2(1, 1), Vector2((power_bar_size.x - 2) * ratio, power_bar_size.y - 2)), Color(0.95, 0.8, 0.2), true)

	if cast_visual_state == CAST_IDLE:
		return

	var start = get_cast_start_offset()
	var end_offset = get_cast_end_offset()
	if cast_visual_state == CAST_WAITING:
		end_offset.y += sin(Time.get_ticks_msec() * 0.01) * 2.0
	var end = start + end_offset
	var line_points = get_line_curve_points(start, end)
	draw_polyline(line_points, Color(0.92, 0.92, 0.95), 2.0, true)
	draw_circle(end, 4.0, Color(0.95, 0.2, 0.2))
	bobber_global_pos = end
	
	
	

func on_casting_finished():
	if $Sprite2D.animation == "cast":
		$Sprite2D.play("fish")
		state = "fish"
		spawn_fishing_bob()
		is_charging_cast = false
		

	if $Sprite2D.animation == "hook":
		$Sprite2D.play("idle")
		state = "idle"
		cast_visual_state = CAST_IDLE
		cast_distance = 0.0
		is_charging_cast = false
		charge_time = 0.0
		queue_redraw()

var fishing_bob_scene = preload("res://scenes/fishingbob.tscn")
var fishing_bob = null
func spawn_fishing_bob(): 
	
	if fishing_bob == null:
		fishing_bob = fishing_bob_scene.instantiate()
		fishing_bob.position = bobber_global_pos
		add_child(fishing_bob)

func kill_fishing_bob():
	if fishing_bob != null:
		fishing_bob.queue_free()
		fishing_bob = null
	
	
	
	
			
				
				
