extends Area2D

var player_in_range: CharacterBody2D = null

func _ready() -> void:
	body_entered.connect(_on_interaction_area_body_entered)
	body_exited.connect(_on_interaction_area_body_exited)

func _physics_process(_delta: float) -> void:
	if player_in_range == null:
		return

	if Input.is_action_just_pressed("sell"):
		var sold_amount := GameState.sell_all_fish()
		if sold_amount > 0:
			print("Sold all fish for P%d" % sold_amount)
		else:
			print("No fish in inventory to sell.")

	if Input.is_action_just_pressed("refuel"):
		if GameState.buy_gas():
			print("Refueled at the talipapa! Gas: %d, Money: %d" % [GameState.current_gas, GameState.current_money])
		else:
			print("Not enough money to refuel at the talipapa.")

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.name == "Fisherman":
		player_in_range = body
		print("Press Q to sell fish or R to refuel at the talipapa")

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
