extends Node2D

var player_in_range: CharacterBody2D = null

@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	if interaction_area == null:
		push_warning("SleepZone is missing child Area2D named 'InteractionArea'.")
		return

	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _physics_process(_delta: float) -> void:
	if player_in_range != null and Input.is_action_just_pressed("interact"):
		GameState.sleep_until_morning()
		print("Slept until morning.")

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Fisherman":
		player_in_range = body
		print("Press E to sleep")

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null