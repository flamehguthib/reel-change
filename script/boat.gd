extends CharacterBody2D

@export var move_speed := 80.0
@export var dismount_offset := Vector2(36, -8)

@onready var interact_area: Area2D = get_node_or_null("Area2D") as Area2D
@onready var mount_point: Marker2D = $MountPoint
@onready var boat_sprite: Sprite2D = $Sprite2D

var rider: CharacterBody2D = null

func _ready() -> void:
	add_to_group("boats")
	if interact_area == null:
		interact_area = get_node_or_null("InteractionArea") as Area2D
	if interact_area != null:
		interact_area.body_entered.connect(_on_interact_area_body_entered)
		interact_area.body_exited.connect(_on_interact_area_body_exited)

func _physics_process(_delta: float) -> void:
	if rider == null:
		velocity = Vector2.ZERO
		return

	var dir := Input.get_action_strength("right") - Input.get_action_strength("left")
	velocity.x = dir * move_speed
	velocity.y = 0.0
	if boat_sprite != null:
		if dir < 0.0:
			boat_sprite.flip_h = true
		elif dir > 0.0:
			boat_sprite.flip_h = false
	move_and_slide()

	if rider != null:
		rider.global_position = mount_point.global_position

func get_mount_position() -> Vector2:
	return mount_point.global_position

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
	mounted_player.global_position = global_position + dismount_offset

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.has_method("set_nearby_boat"):
		body.call("set_nearby_boat", self)

func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.has_method("clear_nearby_boat"):
		body.call("clear_nearby_boat", self)
