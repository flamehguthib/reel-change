extends CanvasLayer

@onready var panel: Panel = get_node_or_null("Panel")
@onready var grid: GridContainer = get_node_or_null("Panel/GridContainer")
@onready var money_label: Label = get_node_or_null("Panel/MoneyLabel")
@onready var close_button: Button = get_node_or_null("Panel/CloseButton")

var item_icons: Dictionary = {
	"tilapia": "res://assets/fish/tilapia.png",
	"galunggong": "res://assets/fish/galunggong.png",
	"bangus": "res://assets/fish/bangus.png",
	"alimango": "res://assets/fish/alimango.png",
	"lapulapu": "res://assets/fish/lapulapu.png",
	"hipon_bait": "res://assets/ui/shirmp.png",
	"tahong_bait": "res://assets/ui/mussels.png",
}

func _ready() -> void:
	if panel:
		panel.visible = false
	refresh()

func _process(_delta: float) -> void:
	if panel and panel.visible and Input.is_action_just_pressed("ESC"):
		close_inventory()

func open_inventory() -> void:
	if panel:
		panel.visible = true
	get_tree().paused = true
	refresh()

func close_inventory() -> void:
	if panel:
		panel.visible = false
	get_tree().paused = false

func is_open() -> bool:
	return panel != null and panel.visible

func refresh() -> void:
	if not grid:
		return
	# Clear existing slots
	for child in grid.get_children():
		child.queue_free()
	# Fish inventory
	var counts: Dictionary = {}
	for fish_id in GameState.fish_inventory:
		counts[fish_id] = counts.get(fish_id, 0) + 1
	for fish_id in counts:
		_add_slot(fish_id, counts[fish_id])
	# Generic inventory items
	for item_id in GameState.inventory.keys():
		_add_slot(item_id, GameState.inventory[item_id])
	if money_label:
		money_label.text = "Money: P%d" % GameState.current_money

func _add_slot(item_id: String, count: int) -> void:
	var slot := VBoxContainer.new()
	slot.custom_minimum_size = Vector2(64, 80)
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(48, 48)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var path: String = item_icons.get(item_id, "res://assets/ui/box.png")
	if ResourceLoader.exists(path):
		icon.texture = load(path)
	slot.add_child(icon)
	var label := Label.new()
	label.text = "%s x%d" % [item_id.capitalize(), count]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot.add_child(label)
	grid.add_child(slot)
