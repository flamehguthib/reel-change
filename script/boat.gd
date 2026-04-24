extends CharacterBody2D

@export var move_speed := 1000
@export var dismount_offset := Vector2(100, -100)
@export var rider_offset_right := Vector2(0, 0)
@export var rider_offset_left := Vector2(0, 0)

@onready var interact_area: Area2D = get_node_or_null("Area2D") as Area2D
@onready var mount_point: Marker2D = $MountPoint
@onready var boat_sprite: AnimatedSprite2D = $AnimatedSprite2D

var rider: CharacterBody2D = null
@onready var nearest_port = Vector2.ZERO

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

	var dir := Input.get_action_strength("right") - Input.get_action_strength("left")

	velocity.x = dir * move_speed
	velocity.y = 0.0
	if boat_sprite != null:
		if dir < 0.0:
			boat_sprite.flip_h = true
		elif dir > 0.0:
			boat_sprite.flip_h = false

		if abs(dir) > 0.01:
			if not boat_sprite.is_playing():
				boat_sprite.play("default")
		else:
			if boat_sprite.is_playing():
				boat_sprite.stop()
			boat_sprite.frame = 0
	move_and_slide()

	if rider != null:
		rider.global_position = get_mount_position()

func get_mount_position() -> Vector2:
	var offset := rider_offset_right
	if boat_sprite != null and boat_sprite.flip_h:
		offset = rider_offset_left
	return mount_point.global_position + offset

func mount_player(player: CharacterBody2D) -> void:
	if rider != null or player == null:
		return

	rider = player
	if rider.has_method("set_mounted_boat"):
		rider.call("set_mounted_boat", self)
	rider.global_position = get_mount_position()

func unmount_player(player: CharacterBody2D) -> void:
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
	
