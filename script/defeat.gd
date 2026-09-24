extends "controls.gd"

func _ready() -> void:
	var label := get_node_or_null("Label") as Label
	if label != null:
		var earned := GameState.final_money
		var goal := GameState.money_goal
		var shortfall := goal - earned
		label.text = "YOU LOST!\n\nYou only earned ₱%d.\nYou were ₱%d short for the graduation gift.\nTry again, fisherman." % [earned, shortfall]
