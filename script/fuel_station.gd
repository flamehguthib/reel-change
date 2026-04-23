extends Node2D

var player_in_range: CharacterBody2D = null
var refuel_label: Label = null

@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	if interaction_area == null:
		push_warning("FuelStation is missing child Area2D named 'InteractionArea'.")
		return

	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _physics_process(_delta: float) -> void:
	if player_in_range != null and Input.is_action_just_pressed("interact"):
		if GameState.buy_gas():
			print("Refueled! Gas: %d, Money: %d" % [GameState.current_gas, GameState.current_money])
		else:
			print("Not enough money! Need: %d, Have: %d" % [GameState.gas_refuel_cost, GameState.current_money])

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Fisherman":
		player_in_range = body
		var cost_text = "E to refuel (%dP for +%d gas)" % [GameState.gas_refuel_cost, GameState.gas_refuel_amount]
		print(cost_text)

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
