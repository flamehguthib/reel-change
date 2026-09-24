extends CharacterBody2D

@export var move_speed := 380
@export var dismount_offset := Vector2(100, -100)
@export var rider_offset_right := Vector2(0, 0)
@export var rider_offset_left := Vector2(0, 0)

@onready var interact_area: Area2D = get_node_or_null("Area2D") as Area2D
@onready var mount_point: Marker2D = $MountPoint
@onready var boat_sprite: AnimatedSprite2D = $AnimatedSprite2D

var rider: CharacterBody2D = null
@onready var nearest_port = Vector2.ZERO
var gas_drain_timer := 0.0
const GAS_DRAIN_INTERVAL := 6.0  # 1 gas unit every 6 seconds of driving
const GAS_DRAIN_AMOUNT := 1

var row_energy_drain_timer := 0.0
const ROW_ENERGY_DRAIN_INTERVAL := 2.5 # 1 energy point per 2.5s of rowing

func _ready() -> void:
	add_to_group("boats")
	if interact_area == null:
		interact_area = get_node_or_null("InteractionArea") as Area2D
	if interact_area != null:
		interact_area.body_entered.connect(_on_interact_area_body_entered)
		interact_area.body_exited.connect(_on_interact_area_body_exited)
	if boat_sprite != null:
		boat_sprite.play("default")
		boat_sprite.stop()
		boat_sprite.frame = 0

func _physics_process(_delta: float) -> void:
	if rider == null:
		velocity = Vector2.ZERO
		return

	var rider_is_fishing := false
	if rider.has_method("is_fishing_mode_active"):
		rider_is_fishing = rider.call("is_fishing_mode_active")

	if rider_is_fishing:
		velocity = Vector2.ZERO
		if boat_sprite != null:
			if boat_sprite.is_playing():
				boat_sprite.stop()
			boat_sprite.frame = 0
		move_and_slide()
		rider.global_position = get_mount_position()
		return

	var is_out_of_gas := GameState.current_gas <= 0
	var is_exhausted := GameState.current_energy <= 0
	var dir := Input.get_action_strength("right") - Input.get_action_strength("left")

	# Tow rescue shortcut (Press T when out of gas)
	if is_out_of_gas and Input.is_action_just_pressed("ui_cancel") == false and Input.is_key_pressed(KEY_T):
		attempt_tow_rescue()
		return

	# Calculate dynamic speed based on boat level (Emergency Rowing mode if out of gas)
	var base_speed := move_speed + ((GameState.boat_level - 1) * 90)
	var current_speed: float = base_speed * 0.22 if is_out_of_gas else float(base_speed)

	# If out of gas and exhausted, cannot row!
	if is_out_of_gas and is_exhausted:
		current_speed = 0.0

	velocity.x = dir * current_speed
	velocity.y = 0.0

	if boat_sprite != null:
		if dir < 0.0:
			boat_sprite.flip_h = true
		elif dir > 0.0:
			boat_sprite.flip_h = false

		if abs(dir) > 0.01 and current_speed > 0.0:
			if not boat_sprite.is_playing():
				SoundManager.play_sfx("boat_move")
				SoundManager.stop_sfx("boat_idle")
				boat_sprite.play("default")
			if not is_out_of_gas:
				gas_drain_timer += _delta
				if gas_drain_timer >= GAS_DRAIN_INTERVAL:
					gas_drain_timer = 0.0
					GameState.spend_gas(GAS_DRAIN_AMOUNT)
			else:
				# Sagwan (rowing) consumes stamina/energy continuously
				row_energy_drain_timer += _delta
				if row_energy_drain_timer >= ROW_ENERGY_DRAIN_INTERVAL:
					row_energy_drain_timer = 0.0
					GameState.spend_energy(1)
		else:
			gas_drain_timer = 0.0
			row_energy_drain_timer = 0.0
			if boat_sprite.is_playing():
				SoundManager.stop_sfx("boat_move")
				SoundManager.play_sfx("boat_idle")
				boat_sprite.stop()
			boat_sprite.frame = 0

	move_and_slide()

	if rider != null:
		rider.global_position = get_mount_position()

func attempt_tow_rescue() -> void:
	# Friendly fisherman towing service
	var cost := 30
	if GameState.current_money >= cost:
		GameState.current_money -= cost
		GameState.refuel_gas(5)
		if rider != null and rider.has_method("show_message"):
			rider.call("show_message", "Coast Guard Tow: Returned to port (-₱30, +5 Gas)! 🚤", Color(0.4, 0.9, 0.4))
	else:
		GameState.current_money = 0
		GameState.refuel_gas(3)
		if rider != null and rider.has_method("show_message"):
			rider.call("show_message", "Friendly Tow: Returned to port (Emergency +3 Gas)! 🚤", Color(0.4, 0.9, 0.4))

	global_position.x = 200.0  # Reset position back toward shore/port
	if rider != null:
		rider.global_position = get_mount_position()

func get_mount_position() -> Vector2:
	var offset := rider_offset_right
	if boat_sprite != null and boat_sprite.flip_h:
		offset = rider_offset_left
	return mount_point.global_position + offset

func mount_player(player: CharacterBody2D) -> void:
	SoundManager.play_sfx("boat_idle")
	SoundManager.stop_sfx("walk")
	SoundManager.stop_sfx("walk_on_port")
	if rider != null or player == null:
		return

	rider = player
	if rider.has_method("set_mounted_boat"):
		rider.call("set_mounted_boat", self)
	rider.global_position = get_mount_position()

func unmount_player(player: CharacterBody2D) -> void:
	SoundManager.stop_sfx("boat_idle")
	SoundManager.stop_sfx("boat_move")
	if rider == null or player != rider:
		return

	var mounted_player := rider
	rider = null

	if mounted_player.has_method("set_mounted_boat"):
		mounted_player.call("set_mounted_boat", null)
		mounted_player.global_position = nearest_port
		

func find_nearest_port():
	var ports = get_tree().get_nodes_in_group("Port")
	if ports.size() > 0:
		var target_port = ports[0]
		nearest_port = target_port.global_position

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.has_method("set_nearby_boat"):
		body.call("set_nearby_boat", self)
	
	if body.is_in_group("Player"):
		$E.visible = true
		
	if body.is_in_group("Port"):
		find_nearest_port()
		

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.has_method("clear_nearby_boat"):
		body.call("clear_nearby_boat", self)
	$E.visible = false
	
func setup_boat_camera(zoom_setting: Vector2, limit: Rect2):
	var cam = get_node("%Camera2D")
		
	cam.zoom = zoom_setting
	cam.limit_left = limit.position.x
	cam.limit_top = limit.position.y
	cam.limit_bottom = limit.size.y
	cam.limit_right = limit.size.x
	cam.enabled = true 
	cam.make_current()
