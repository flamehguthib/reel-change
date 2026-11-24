extends CanvasLayer

signal summary_closed

@onready var day_label = $Control/Panel/VBoxContainer/DayLabel
@onready var earnings_label = $Control/Panel/VBoxContainer/EarningsLabel
@onready var family_expenses_label = $Control/Panel/VBoxContainer/FamilyExpensesLabel
@onready var fishing_expenses_label = $Control/Panel/VBoxContainer/FishingExpensesLabel
@onready var net_label = $Control/Panel/VBoxContainer/NetLabel
@onready var continue_button = $Control/Panel/VBoxContainer/ContinueButton
@onready var separator1 = $Control/Panel/VBoxContainer/Separator1
@onready var separator2 = $Control/Panel/VBoxContainer/Separator2

func _ready() -> void:
	# Setup button animations like main menu
	continue_button.pivot_offset = continue_button.size / 2
	continue_button.item_rect_changed.connect(func(): continue_button.pivot_offset = continue_button.size / 2)

	continue_button.mouse_entered.connect(_on_button_hover.bind(continue_button))
	continue_button.mouse_exited.connect(_on_button_unhover.bind(continue_button))
	continue_button.pressed.connect(_on_button_pressed_anim.bind(continue_button))

	# Populate labels from GameState
	var summary = GameState.last_day_summary
	if summary.is_empty():
		# Fallback for testing
		day_label.text = "Day Summary"
		earnings_label.text = "Earnings: +₱0"
		family_expenses_label.text = "  Family: -₱0"
		fishing_expenses_label.text = "  Fishing: -₱0"
		net_label.text = "Net: ₱0"
	else:
		day_label.text = "Summary of Day %d" % summary.get("day", 1)
		earnings_label.text = "Earnings: +₱%d" % summary.get("earnings", 0)
		family_expenses_label.text = "  Family Expenses: -₱%d" % summary.get("family_expenses", 0)
		fishing_expenses_label.text = "  Fishing Costs: -₱%d" % summary.get("fishing_expenses", 0)

		var net = summary.get("net", 0)
		net_label.text = "Net Profit: ₱%d" % net

		if net > 0:
			net_label.add_theme_color_override("font_color", Color.GREEN)
		elif net < 0:
			net_label.add_theme_color_override("font_color", Color.RED)

	continue_button.pressed.connect(_on_continue_pressed)
	# Force focus for gamepad/keyboard support
	continue_button.grab_focus()

func _on_continue_pressed() -> void:
	SoundManager.play_sfx("select")
	summary_closed.emit()
	queue_free()

func _on_button_hover(btn: Button) -> void:
	var tw := create_tween()
	tw.set_parallel(true)
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.2)
	tw.tween_property(btn, "rotation_degrees", 1.0, 0.2)
	tw.tween_property(btn, "modulate", Color.WHITE, 0.2)

func _on_button_unhover(btn: Button) -> void:
	var tw := create_tween()
	tw.set_parallel(true)
	tw.set_trans(Tween.TRANS_SINE)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(btn, "scale", Vector2.ONE, 0.2)
	tw.tween_property(btn, "rotation_degrees", 0.0, 0.2)
	tw.tween_property(btn, "modulate", Color(0.94, 0.94, 0.94), 0.2)

func _on_button_pressed_anim(btn: Button) -> void:
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.1)
	tw.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.1)
