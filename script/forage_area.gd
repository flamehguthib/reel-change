extends Area2D

var player_in_range: CharacterBody2D = null
var has_foraged_today: bool = false
var last_foraged_day: int = -1

@onready var label: Label = get_node_or_null("Label")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if label != null:
		label.visible = false

func _physics_process(_delta: float) -> void:
	if player_in_range == null:
		return

	if Input.is_action_just_pressed("interact"):
		attempt_forage()

func attempt_forage() -> void:
	if last_foraged_day == GameState.current_day:
		_show_hint("Already foraged shoreline today! Check again tomorrow morning.", Color(0.9, 0.7, 0.3))
		return

	# Check time window: 5 AM to 8 AM (low tide)
	var hour := int(GameState.current_time)
	if hour < 5 or hour >= 8:
		_show_hint("Low tide foraging is only available in early morning (5:00 AM - 8:00 AM)!", Color(0.9, 0.6, 0.3))
		return

	last_foraged_day = GameState.current_day
	# Give random bait (1-2 Hipon or 1 Tahong)
	if randf() > 0.5:
		GameState.hipon_bait_count += 2
		_show_hint("Foraged 2x Paong Hipon along the beach rocks! 🦐", Color(0.4, 0.95, 0.5))
	else:
		GameState.tahong_bait_count += 1
		_show_hint("Foraged 1x Paong Tahong attached to the pier! 🦪", Color(0.4, 0.95, 0.5))
	
	SoundManager.play_sfx("select")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name.to_lower() == "fisherman":
		player_in_range = body as CharacterBody2D
		if label != null:
			label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		if label != null:
			label.visible = false

func _show_hint(text: String, color: Color) -> void:
	if player_in_range != null and player_in_range.has_method("show_message"):
		player_in_range.call("show_message", text, color)
	else:
		print(text)
