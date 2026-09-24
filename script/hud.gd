extends CanvasLayer

# ── Time Cycle Sprite Sheet ──────────────────────────────────────────
const TIMECYCLE_SHEET: CompressedTexture2D = preload("res://assets/ui/timecycle.png")
const TIMECYCLE_FRAME_W: float = 128.0
const TIMECYCLE_FRAME_H: float = 128.0

var _timecycle_atlases: Array[AtlasTexture] = []
var _last_time_index: int = -1

# ── Node References ──────────────────────────────────────────────────
@onready var day_label: Label = get_node_or_null("TopBar/Stats/DayLabel") as Label
@onready var time_label: Label = get_node_or_null("TopBar/Stats/TimeLabel") as Label
@onready var energy_label: Label = get_node_or_null("TopBar/Stats/EnergyLabel") as Label
@onready var energy_bar: ProgressBar = get_node_or_null("TopBar/Stats/EnergyBar") as ProgressBar
@onready var gas_label: Label = get_node_or_null("TopBar/Stats/GasLabel") as Label
@onready var gas_bar: ProgressBar = get_node_or_null("TopBar/Stats/GasBar") as ProgressBar
@onready var money_label: Label = get_node_or_null("TopBar/Stats/MoneyLabel") as Label
@onready var goal_label: Label = get_node_or_null("TopBar/Stats/GoalLabel") as Label
@onready var fish_inventory_label: Label = get_node_or_null("TopBar/Stats/FishInventoryLabel") as Label
@onready var weather_label: Label = get_node_or_null("TopBar/Stats/WeatherLabel") as Label
@onready var time_cycle_icon: TextureRect = get_node_or_null("TimeVBox/TimeCycleIcon") as TextureRect
@onready var time_cycle_label: Label = get_node_or_null("TimeVBox/TimeCycleLabel") as Label

func _ready() -> void:
	var panel := get_node_or_null("TopBar") as Panel
	if panel != null:
		panel.size = Vector2(480, 360)
	_build_timecycle_atlases()

func _build_timecycle_atlases() -> void:
	_timecycle_atlases.clear()
	for frame in range(3):
		var atlas := AtlasTexture.new()
		atlas.atlas = TIMECYCLE_SHEET
		atlas.region = Rect2(
			frame * TIMECYCLE_FRAME_W, 0.0,
			TIMECYCLE_FRAME_W, TIMECYCLE_FRAME_H
		)
		_timecycle_atlases.append(atlas)
	# Force initial display so we don't have to wait for _process
	_apply_timecycle_display()

func _process(_delta: float) -> void:
	if day_label != null:
		var weather_icon := "☀️"
		match GameState.weather:
			GameState.WEATHER_CLOUDY: weather_icon = "⛅"
			GameState.WEATHER_RAIN: weather_icon = "🌧️"
			GameState.WEATHER_STORM: weather_icon = "🌩️"
		day_label.text = "Day %d / %d  |  %s  |  %s %s" % [
			GameState.current_day, 
			GameState.max_days, 
			GameState.get_time_of_day(), 
			weather_icon, 
			GameState.weather
		]

	# ── Time Cycle Sprite ─────────────────────────────────────────────
	_apply_timecycle_display()

	if time_label != null:
		var player_node: Node2D = get_tree().get_first_node_in_group("Player") as Node2D
		var zone_str := "Aplaya (Town Shore)"
		if player_node != null and get_tree().current_scene.name == "OpenSea":
			zone_str = GameState.get_sea_zone(player_node.global_position.x)
		time_label.text = "Location: %s" % zone_str

	if money_label != null:
		var pct := int((float(GameState.current_money) / float(GameState.money_goal)) * 100.0)
		money_label.text = "IPON: ₱%d / ₱%d (%d%% - Graduation Gift 🎓)" % [
			GameState.current_money, 
			GameState.money_goal,
			pct
		]
		if GameState.current_money >= GameState.money_goal:
			money_label.add_theme_color_override("font_color", Color.GREEN)
		else:
			money_label.add_theme_color_override("font_color", Color.YELLOW)

	if goal_label != null:
		var bait_str := "Kawil [1]"
		if GameState.active_bait == "hipon":
			bait_str = "Paong Hipon (%d left) [2]" % GameState.hipon_bait_count
		elif GameState.active_bait == "tahong":
			bait_str = "Paong Tahong (%d left) [3]" % GameState.tahong_bait_count
		goal_label.text = "Active Paon: %s  (Hotkeys: [1] Kawil  [2] Hipon  [3] Tahong)" % bait_str

	if fish_inventory_label != null:
		var prog := GameState.get_contract_progress()
		if not GameState.active_contract.is_empty():
			var title: String = GameState.active_contract.get("title", "")
			if prog.completed:
				fish_inventory_label.text = "Order: %s [DONE ✔]" % title
				fish_inventory_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
			elif prog.ready:
				fish_inventory_label.text = "Order: %s (%d/%d) [READY AT TALIPAPA!]" % [title, prog.in_bag, prog.required]
				fish_inventory_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
			else:
				fish_inventory_label.text = "Order: %s (%d/%d in bag)" % [title, prog.in_bag, prog.required]
				fish_inventory_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		else:
			fish_inventory_label.text = "Fish Stock: %d fish (P%d)" % [GameState.get_fish_inventory_count(), GameState.get_fish_inventory_value()]

	if weather_label != null:
		var player_node: Node2D = get_tree().get_first_node_in_group("Player") as Node2D
		var nav_hint := ""
		if player_node != null:
			var scene_name := get_tree().current_scene.name
			if scene_name == "OpenSea":
				var dist_to_port: int = int(player_node.global_position.x)
				var gas_status := ""
				if GameState.current_gas <= 0:
					if GameState.current_energy <= 0:
						gas_status = " [🛑 EXHAUSTED! Cannot Row | Press T for Tow Rescue]"
					else:
						gas_status = " [⚠️ SAGWAN: Rowing Drains Energy! | Press T for Tow]"
				nav_hint = "  |  ⬅ Port: %dm%s" % [dist_to_port, gas_status]
			elif scene_name == "main_scene":
				var px: float = player_node.global_position.x
				if px < 800:
					nav_hint = "  |  Nav: 🏠 Sleep Zone [Here]  ➡ Talipapa / Sea"
				elif px > 3000:
					nav_hint = "  |  Nav: ⬅ Sleep Zone / Talipapa  🌊 Open Sea Border [Here]"
				else:
					nav_hint = "  |  Nav: ⬅ Sleep Zone  🏪 Talipapa  ➡ Open Sea"
		weather_label.text = "Bag: %d fish (₱%d value)%s" % [GameState.get_fish_inventory_count(), GameState.get_fish_inventory_value(), nav_hint]

	if energy_label != null:
		energy_label.text = "Lakas (Energy): %d / %d" % [GameState.current_energy, GameState.max_energy]
		if GameState.current_energy < 20:
			energy_label.add_theme_color_override("font_color", Color.RED)
		else:
			energy_label.add_theme_color_override("font_color", Color.WHITE)

	if energy_bar != null:
		energy_bar.max_value = GameState.max_energy
		energy_bar.value = GameState.current_energy

	if gas_label != null:
		gas_label.text = "Kargang Krudo (Gas): %d / %d" % [GameState.current_gas, GameState.max_gas]
		if GameState.current_gas < 20:
			gas_label.add_theme_color_override("font_color", Color.ORANGE_RED)
		else:
			gas_label.add_theme_color_override("font_color", Color.WHITE)

	if gas_bar != null:
		gas_bar.max_value = GameState.max_gas
		gas_bar.value = GameState.current_gas

# ── Time Cycle Helpers ───────────────────────────────────────────────

func _apply_timecycle_display() -> void:
	if _timecycle_atlases.is_empty():
		return
	var time_idx: int = clampi(GameState.current_time_index, 0, _timecycle_atlases.size() - 1)

	# Only swap texture when the period actually changed
	if time_cycle_icon != null and time_idx != _last_time_index:
		time_cycle_icon.texture = _timecycle_atlases[time_idx]
		_last_time_index = time_idx

	if time_cycle_label != null:
		time_cycle_label.text = GameState.get_time_of_day()
