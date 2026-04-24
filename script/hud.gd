extends CanvasLayer

@onready var day_label: Label = $TopBar/Stats/DayLabel
@onready var time_label: Label = $TopBar/Stats/TimeLabel
@onready var energy_label: Label = $TopBar/Stats/EnergyLabel
@onready var energy_bar: ProgressBar = $TopBar/Stats/EnergyBar
@onready var gas_label: Label = $TopBar/Stats/GasLabel
@onready var gas_bar: ProgressBar = $TopBar/Stats/GasBar
@onready var money_label: Label = $TopBar/Stats/MoneyLabel
@onready var goal_label: Label = $TopBar/Stats/GoalLabel
@onready var fish_inventory_label: Label = get_node_or_null("TopBar/Stats/FishInventoryLabel") as Label

func _ready() -> void:
	# Expand panel to fit all labels cleanly.
	var panel := $TopBar as Panel
	if panel != null:
		panel.size = Vector2(360, 260)

func _process(_delta: float) -> void:
	day_label.text = "Day: %d / %d" % [GameState.current_day, GameState.max_days]
	time_label.text = "Time: %s" % GameState.get_time_of_day()
	energy_label.text = "Energy: %d / %d" % [GameState.current_energy, GameState.max_energy]
	energy_bar.max_value = GameState.max_energy
	energy_bar.value = GameState.current_energy
	gas_label.text = "Gas: %d / %d" % [GameState.current_gas, GameState.max_gas]
	gas_bar.max_value = GameState.max_gas
	gas_bar.value = GameState.current_gas
	money_label.text = "Money: P%d" % GameState.current_money
	goal_label.text = "Goal: P%d" % GameState.money_goal
	if fish_inventory_label != null:
		fish_inventory_label.text = "Fish Stock: %d fish (P%d)" % [GameState.fish_inventory_count, GameState.fish_inventory_value]
	
	# Color feedback
	if GameState.current_energy < 20:
		energy_label.add_theme_color_override("font_color", Color.RED)
	else:
		energy_label.add_theme_color_override("font_color", Color.WHITE)

	if GameState.current_gas < 20:
		gas_label.add_theme_color_override("font_color", Color.ORANGE_RED)
	else:
		gas_label.add_theme_color_override("font_color", Color.WHITE)
	
	if GameState.current_money >= GameState.money_goal:
		money_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		money_label.add_theme_color_override("font_color", Color.WHITE)
