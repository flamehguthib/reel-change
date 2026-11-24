extends CanvasLayer

func _ready() -> void:
	# Setup button animations like main menu
	for btn in $VBoxContainer.get_children():
		if btn is Button:
			btn.pivot_offset = btn.size / 2
			btn.item_rect_changed.connect(func(): btn.pivot_offset = btn.size / 2)

			btn.mouse_entered.connect(_on_button_hover.bind(btn))
			btn.mouse_exited.connect(_on_button_unhover.bind(btn))
			btn.pressed.connect(_on_button_pressed_anim.bind(btn))

	_update_mute_button_text()

func _process(_delta):
	if not Input.is_action_just_pressed("ESC"):
		return

	# Don't toggle pause if a shop panel is open
	var shop_open := false
	for shop in get_tree().get_nodes_in_group("shop_open"):
		if shop != null and shop.has_method("is_open") and shop.is_open():
			shop_open = true
			break
	if shop_open:
		return

	if visible:
		visible = false
		get_tree().paused = false
	else:
		visible = true
		get_tree().paused = true

func _on_continue_pressed() -> void:
	SoundManager.play_sfx("select")
	get_tree().paused = false
	visible = false

func _on_main_menu_pressed() -> void:
	SoundManager.play_sfx("select")
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_exit_pressed() -> void:
	SoundManager.play_sfx("select")
	get_tree().quit()

func _on_fucking_mute_pressed() -> void:
	SoundManager.play_sfx("select")
	var master_bus := AudioServer.get_bus_index("Master")
	var is_muted := AudioServer.is_bus_mute(master_bus)
	AudioServer.set_bus_mute(master_bus, not is_muted)
	_update_mute_button_text()

func _update_mute_button_text() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	var is_muted := AudioServer.is_bus_mute(master_bus)
	$VBoxContainer/Mute.text = "Unmute" if is_muted else "Mute"

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
