extends Node2D

var player_in_range: CharacterBody2D = null
var is_sleeping := false

@onready var interaction_area: Area2D = get_node_or_null("InteractionArea")
@onready var sleep_label = get_node_or_null("InteractionArea/CollisionShape2D/SleepLabel")

func _ready() -> void:
	if interaction_area == null:
		push_warning("SleepZone is missing child Area2D named 'InteractionArea'.")
		return

	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _physics_process(_delta: float) -> void:
	if player_in_range != null and not is_sleeping and Input.is_action_just_pressed("interact"):
		is_sleeping = true
		if sleep_label:
			sleep_label.visible = false
		if Transition_Manager and Transition_Manager.has_method("fade_out_in"):
			Transition_Manager.fade_out_in(Callable(self, "_perform_sleep"))
		else:
			_perform_sleep()

func _perform_sleep() -> void:
	GameState.sleep_until_morning()
	print("Slept until morning.")
	is_sleeping = false
	if player_in_range != null and sleep_label != null:
		sleep_label.visible = true

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name.to_lower() == "fisherman":
		player_in_range = body as CharacterBody2D
		if sleep_label and not is_sleeping:
			sleep_label.visible = true
		print("Press E to sleep")

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
		if sleep_label:
			sleep_label.visible = false
