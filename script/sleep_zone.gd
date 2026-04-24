extends Node2D

var player_in_range: CharacterBody2D = null

@onready var interaction_area: Area2D = $InteractionArea
@onready var sleep_label = $InteractionArea/CollisionShape2D/SleepLabel

func _ready() -> void:
	if interaction_area == null:
		push_warning("SleepZone is missing child Area2D named 'InteractionArea'.")
		return

	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _physics_process(_delta: float) -> void:
	if player_in_range != null and Input.is_action_just_pressed("interact"):
		Transition_Manager.transition_to_cutscene()
		GameState.sleep_until_morning()
		print("Slept until morning.")

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Fisherman":
		player_in_range = body
		sleep_label.visible = true
		print("Press E to sleep")

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		sleep_label.visible = false
