extends "controls.gd"

func _ready() -> void:
	var label := get_node_or_null("Label") as Label
	if label != null:
		var earned := GameState.final_money
		var goal := GameState.money_goal
		label.text = "CONGRATULATIONS!\n\nYou earned ₱%d for your daughter's graduation gift!\n(Goal: ₱%d)" % [earned, goal]
