extends CanvasLayer

signal next_day_pressed

const ROW_SCENE: PackedScene = preload("res://scenes/ui/ReceiptRow.tscn")
const COLOR_PROFIT := Color(0.12, 0.55, 0.25, 1.0)
const COLOR_LOSS := Color(0.75, 0.16, 0.16, 1.0)

@onready var receipt_paper: PanelContainer = %ReceiptPaper
@onready var header_label: Label = %HeaderLabel
@onready var sub_header_label: Label = %SubHeaderLabel
@onready var catch_list: VBoxContainer = %CatchList
@onready var expense_list: VBoxContainer = %ExpenseList
@onready var net_amount: Label = %NetAmount
@onready var secondary_box: PanelContainer = %SecondaryBox
@onready var secondary_label: Label = %SecondaryLabel
@onready var stamp_label: Label = %StampLabel
@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	continue_button.pressed.connect(func() -> void:
		next_day_pressed.emit()
		hide()
	)


func show_summary(ledger: Dictionary) -> void:
	show()
	header_label.text = "PALENGKE LEDGER - DAY %d" % ledger.get("day", 1)
	sub_header_label.text = "WEATHER: %s" % str(ledger.get("weather", "NORMAL")).to_upper()

	_clear_children(catch_list)
	_clear_children(expense_list)

	var gross := 0
	var catches: Dictionary = ledger.get("catches", {})
	for fish_name: String in catches:
		var data: Dictionary = catches[fish_name]
		var subtotal: int = data.get("total", 0)
		gross += subtotal
		_add_row(catch_list, "%s x%d" % [fish_name, data.get("count", 1)], "₱%d" % subtotal, Color(0.18, 0.15, 0.12))

	var spent := 0
	var expenses: Array = ledger.get("expenses", [])
	for item: Dictionary in expenses:
		var cost: int = item.get("amount", 0)
		spent += cost
		_add_row(expense_list, item.get("label", "Expense"), "-₱%d" % cost, COLOR_LOSS)

	var net := gross - spent
	var is_profit := net >= 0
	var active_color := COLOR_PROFIT if is_profit else COLOR_LOSS

	net_amount.text = ("%s₱%d" % ["+" if is_profit else "-", abs(net)])
	net_amount.add_theme_color_override("font_color", active_color)

	var pearls: int = ledger.get("secondary_earned", 0)
	secondary_box.visible = pearls > 0
	if pearls > 0:
		secondary_label.text = "+%d PEARLS COLLECTED" % pearls

	_update_stamp(is_profit, active_color)
	_play_print_animation()


func _add_row(parent: VBoxContainer, item_text: String, price_text: String, price_color: Color) -> void:
	var row: HBoxContainer = ROW_SCENE.instantiate()
	row.get_node("ItemLabel").text = item_text
	var price_lbl: Label = row.get_node("PriceLabel")
	price_lbl.text = price_text
	price_lbl.add_theme_color_override("font_color", price_color)
	parent.add_child(row)


func _update_stamp(is_profit: bool, color: Color) -> void:
	stamp_label.text = "KITA" if is_profit else "LUGI"
	stamp_label.add_theme_color_override("font_color", color)
	var style := stamp_label.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	style.border_color = color
	stamp_label.add_theme_stylebox_override("normal", style)


func _play_print_animation() -> void:
	await get_tree().process_frame
	var target_y := receipt_paper.position.y
	receipt_paper.position.y += 180.0
	receipt_paper.modulate.a = 0.0
	stamp_label.scale = Vector2(2.2, 2.2)
	stamp_label.modulate.a = 0.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(receipt_paper, "position:y", target_y, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(receipt_paper, "modulate:a", 1.0, 0.2)

	tween.chain().set_parallel(true)
	tween.tween_property(stamp_label, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(stamp_label, "modulate:a", 1.0, 0.1)


func _clear_children(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()
