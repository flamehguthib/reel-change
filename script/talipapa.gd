extends Area2D

var player_in_range: CharacterBody2D = null
var shop_scene = preload("res://scenes/ui/talipapa_shop.tscn")
var shop = null

func _ready() -> void:
	body_entered.connect(_on_interaction_area_body_entered)
	body_exited.connect(_on_interaction_area_body_exited)

func _physics_process(_delta: float) -> void:
	if player_in_range == null:
		return

	if Input.is_action_just_pressed("sell") and not is_shop_open():
		open_shop()
	elif Input.is_action_just_pressed("interact") and not is_shop_open():
		open_shop()

func is_shop_open() -> bool:
	return shop != null and shop.is_open()

func open_shop() -> void:
	if shop == null:
		shop = shop_scene.instantiate()
		add_child(shop)
	shop.open_shop()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name.to_lower() == "fisherman":
		player_in_range = body as CharacterBody2D
		$Label.visible = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		$Label.visible = false
