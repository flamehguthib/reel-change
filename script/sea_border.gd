extends Area2D

@export_file("*.tscn") var target_scene_path: String = ""
@export var require_gas_to_cross: bool = true

@onready var sail_prompt: Sprite2D = $SailPrompt if has_node("SailPrompt") else $ReturnPrompt if has_node("ReturnPrompt") else null
var boat_nearby: CharacterBody2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Hide prompt on start
	if sail_prompt != null:
		sail_prompt.visible = false

func _physics_process(_delta: float) -> void:
	# Check for E key input when boat is nearby and prompt is visible
	if sail_prompt != null and sail_prompt.visible and Input.is_action_just_pressed("interact"):
		_attempt_sail()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("boats"):
		return
	
	boat_nearby = body
	
	# Show prompt
	if sail_prompt != null:
		sail_prompt.visible = true

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("boats"):
		return
	
	boat_nearby = null
	
	# Hide prompt
	if sail_prompt != null:
		sail_prompt.visible = false

func _attempt_sail() -> void:
	if target_scene_path.is_empty():
		return

	# Only require gas when sailing OUT to open sea (returning to town is always free)
	var is_returning_to_town: bool = target_scene_path.contains("main_scene")
	if require_gas_to_cross and not is_returning_to_town and not GameState.can_travel_to_opensea():
		_show_hint("Not enough gas to sail out! Need %d gas." % GameState.gas_cost_to_opensea)
		return

	# Spend gas only when sailing outward to open sea
	if require_gas_to_cross and not is_returning_to_town:
		SoundManager.stop_sfx("boat_move")
		GameState.travel_to_opensea()
	else:
		SoundManager.stop_sfx("boat_move")
	
	GameState.current_time_index += 1
	get_tree().change_scene_to_file(target_scene_path)

func _show_hint(text: String) -> void:
	var rider = get_tree().get_first_node_in_group("Player")
	if rider != null and rider.has_method("show_message"):
		rider.call("show_message", text, Color(0.95, 0.3, 0.3))
	else:
		print(text)
