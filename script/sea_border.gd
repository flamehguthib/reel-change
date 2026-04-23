extends Area2D

@export_file("*.tscn") var target_scene_path: String = ""
@export var require_gas_to_cross: bool = true
@export var popup_message: Label = null

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

	# Check gas requirement
	if require_gas_to_cross and not GameState.can_travel_to_opensea():
		print("Not enough gas! Need %d, have %d" % [GameState.gas_cost_to_opensea, GameState.current_gas])
		return

	# Spend gas and transition
	if require_gas_to_cross:
		GameState.travel_to_opensea()
	
	get_tree().change_scene_to_file(target_scene_path)

