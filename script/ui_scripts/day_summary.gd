extends CanvasLayer

signal summary_closed

@onready var day_label = $Control/Panel/VBoxContainer/DayLabel
@onready var earnings_label = $Control/Panel/VBoxContainer/EarningsLabel
@onready var expenses_label = $Control/Panel/VBoxContainer/ExpensesLabel
@onready var net_label = $Control/Panel/VBoxContainer/NetLabel
@onready var continue_button = $Control/Panel/VBoxContainer/ContinueButton

func _ready() -> void:
	# Populate labels from GameState
	var summary = GameState.last_day_summary
	if summary.is_empty():
		# Fallback for testing
		day_label.text = "Day Summary"
		earnings_label.text = "Earnings: ₱0"
		expenses_label.text = "Expenses: -₱0"
		net_label.text = "Net: ₱0"
	else:
		day_label.text = "Summary of Day %d" % summary.get("day", 1)
		earnings_label.text = "Earnings: +₱%d" % summary.get("earnings", 0)
		expenses_label.text = "Expenses: -₱%d" % summary.get("expenses", 0)
		
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
	summary_closed.emit()
	queue_free()
