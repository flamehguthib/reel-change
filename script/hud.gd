extends CanvasLayer

@onready var day_label: Label = $TopBar/Stats/DayLabel
@onready var time_label: Label = $TopBar/Stats/TimeLabel
@onready var energy_label: Label = $TopBar/Stats/EnergyLabel
@onready var money_label: Label = $TopBar/Stats/MoneyLabel
@onready var goal_label: Label = $TopBar/Stats/GoalLabel

func _ready() -> void:
	# Expand panel to fit all labels cleanly.
	var panel := $TopBar as Panel
	if panel != null:
		panel.size = Vector2(320, 180)

func _process(_delta: float) -> void:
	day_label.text = "Day: %d / %d" % [GameState.current_day, GameState.max_days]
	time_label.text = "Time: %s" % GameState.get_time_of_day()
	energy_label.text = "Energy: %d / %d" % [GameState.current_energy, GameState.max_energy]
	money_label.text = "Money: P%d" % GameState.current_money
	goal_label.text = "Goal: P%d" % GameState.money_goal
	
	# Color feedback
	if GameState.current_energy < 20:
		energy_label.add_theme_color_override("font_color", Color.RED)
	else:
		energy_label.add_theme_color_override("font_color", Color.WHITE)
	
	if GameState.current_money >= GameState.money_goal:
		money_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		money_label.add_theme_color_override("font_color", Color.WHITE)
