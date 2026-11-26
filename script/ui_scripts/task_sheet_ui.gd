extends CanvasLayer

signal goal_claimed

var _row_scene: PackedScene
var _heartbeat: float = 0.0
var _overlay: ColorRect = null

@onready var hud_button: Button = %TaskHUDButton
@onready var popup_container: CenterContainer = %PopupContainer
@onready var close_button: Button = %CloseButton
@onready var goal_progress: ProgressBar = %GoalProgress
@onready var goal_amount_label: Label = %GoalAmountLabel
@onready var claim_goal_button: Button = %ClaimGoalButton
@onready var delivery_list: VBoxContainer = %DeliveryList

# This sheet is a pure VIEW of GameState. All listahan state (delivery
# progress, goal, claim flag) lives in GameState so it persists across
# scenes and any catch, out at sea or at dock, updates it in real time.

func _ready() -> void:
	_row_scene = load("res://scenes/ui/MarketOrderRow.tscn")
	if _row_scene == null:
		push_warning("Could not load MarketOrderRow.tscn")

	if hud_button:
		hud_button.pressed.connect(_on_hud_pressed)
	if close_button:
		close_button.pressed.connect(_hide_sheet)
	if claim_goal_button:
		claim_goal_button.pressed.connect(_on_claim_goal)

	# Live-update whenever a catch/deliver/claim changes the sheet state
	if GameState.has_signal("task_sheet_changed"):
		GameState.task_sheet_changed.connect(_on_state_changed)

	_refresh_delivery_rows()
	_update_goal_display()
	_update_hud_label()

func _process(delta: float) -> void:
	# The goal tracks the shared wallet, so any money change should reflect
	# here even when no listahan event fired. Cheap to update every 3s.
	_heartbeat += delta
	if _heartbeat >= 3.0:
		_heartbeat = 0.0
		_update_goal_display()
		_update_hud_label()

func _on_state_changed() -> void:
	_refresh_delivery_rows()
	_update_goal_display()
	_update_hud_label()

func _unhandled_input(event: InputEvent) -> void:
	# Press T key to force-toggle the sheet (debug)
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		_on_hud_pressed()
		get_viewport().set_input_as_handled()

func _on_hud_pressed() -> void:
	if popup_container.visible:
		_hide_sheet()
		return

	_refresh_delivery_rows()
	_update_goal_display()
	popup_container.show()

	# Show dark overlay behind the pad (visual only, doesn't block input)
	if _overlay == null:
		_overlay = ColorRect.new()
		_overlay.color = Color(0.05, 0.05, 0.1, 0.65)
		_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_overlay)
		_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		_overlay.z_index = -1
		_overlay.show()

func _hide_sheet() -> void:
	popup_container.hide()
	if _overlay:
		_overlay.hide()

func _on_claim_goal() -> void:
	if GameState.ts_goal_reached() and not GameState.ts_goal_claimed:
		GameState.ts_claim_goal()
		goal_claimed.emit()

func _refresh_delivery_rows() -> void:
	if delivery_list == null or _row_scene == null:
		return

	for child in delivery_list.get_children():
		child.queue_free()

	for item in GameState.ts_deliveries:
		var row: PanelContainer = _row_scene.instantiate()
		row.get_node("%StallLabel").text = item.stall
		row.get_node("%OrderDesc").text = "Deliver %s x%d (%d/%d)" % [item.fish, item.target, item.current, item.target]
		row.get_node("%RewardLabel").text = "+P%d" % item.pesos

		var btn: Button = row.get_node("%DeliverButton")
		if item.delivered:
			btn.text = "DELIVERED"
			btn.disabled = true
			row.modulate = Color(0.75, 0.72, 0.58, 0.65)
		elif item.current >= item.target:
			btn.text = "DELIVER"
			btn.disabled = false
			btn.pressed.connect(_make_deliver_callable(item))
		else:
			btn.text = "PENDING"
			btn.disabled = true

		delivery_list.add_child(row)

func _make_deliver_callable(item: Dictionary) -> Callable:
	return func() -> void:
		print("DELIVER button clicked for: %s" % item.fish)
		# Payment + progress all handled inside GameState (wallet + signal).
		GameState.ts_deliver_order(item.fish)

func _update_goal_display() -> void:
	var wallet := GameState.current_money
	var target := GameState.money_goal

	if goal_progress:
		goal_progress.max_value = target
		goal_progress.value = min(wallet, target)

	if goal_amount_label:
		goal_amount_label.text = "P%d / P%d" % [wallet, target]

	if claim_goal_button:
		if GameState.ts_goal_claimed:
			claim_goal_button.text = "CLAIMED!"
			claim_goal_button.disabled = true
		elif GameState.ts_goal_reached():
			claim_goal_button.text = "CLAIM"
			claim_goal_button.disabled = false
		else:
			claim_goal_button.text = "IN PROGRESS"
			claim_goal_button.disabled = true

func _update_hud_label() -> void:
	if hud_button:
		hud_button.text = "LISTAHAN (%d)" % GameState.ts_get_open_count()
