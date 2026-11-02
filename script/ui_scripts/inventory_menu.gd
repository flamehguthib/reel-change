extends CanvasLayer

var is_open := false

@onready var panel = $Control/Panel
@onready var grid_container = $Control/Panel/GridContainer

func _ready():
	panel.visible = false
	update_inventory_display()

func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_inventory():
	is_open = !is_open
	panel.visible = is_open
	if is_open:
		update_inventory_display()
		get_tree().paused = true
	else:
		get_tree().paused = false

func update_inventory_display():
	# Clear existing items
	for child in grid_container.get_children():
		child.queue_free()
	
	# Add items from GameState
	var inv = GameState.inventory
	for item_id in inv.keys():
		var count = inv[item_id]
		var item_label = Label.new()
		item_label.text = "%s: x%d" % [item_id.capitalize(), count]
		grid_container.add_child(item_label)
	
	if inv.is_empty():
		var empty_label = Label.new()
		empty_label.text = "Inventory is empty"
		grid_container.add_child(empty_label)
