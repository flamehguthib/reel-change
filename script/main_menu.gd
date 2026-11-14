extends Control

func _ready():
	SoundManager.play_sfx("main_menu")
	
	# Intro animation
	$VBoxContainer.modulate.a = 0
	$VBoxContainer.position.y += 50
	var intro_tw := create_tween().set_parallel(true)
	intro_tw.tween_property($VBoxContainer, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE)
	intro_tw.tween_property($VBoxContainer, "position:y", $VBoxContainer.position.y - 50, 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Title breathing animation
	_animate_title()
	
	for btn in $VBoxContainer.get_children():
		if btn is Button:
			# Ensure pivot is centered for scaling
			btn.pivot_offset = btn.size / 2
			btn.item_rect_changed.connect(func(): btn.pivot_offset = btn.size / 2)
			
			btn.mouse_entered.connect(_on_button_hover.bind(btn))
			btn.mouse_exited.connect(_on_button_unhover.bind(btn))
			btn.pressed.connect(_on_button_pressed_anim.bind(btn))
	
	_update_mute_button_text()

func _animate_title() -> void:
	var title := $CanvasLayer/TitleCard
	title.pivot_offset = title.size / 2
	var tw := create_tween().set_loops()
	tw.tween_property(title, "scale", Vector2(0.95, 0.95), 2.0).set_trans(Tween.TRANS_SINE)
	tw.tween_property(title, "scale", Vector2(0.9, 0.9), 2.0).set_trans(Tween.TRANS_SINE)

func _update_mute_button_text() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	var is_muted := AudioServer.is_bus_mute(master_bus)
	$VBoxContainer/Options.text = "Unmute" if is_muted else "Mute"

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

func _on_play_pressed() -> void:
	SoundManager.play_sfx("select")
	tree_exiting.connect(on_scene_left)
	get_tree().change_scene_to_file("res://scenes/ui/opening_cutscene.tscn"	)

func _on_exit_pressed() -> void:
	SoundManager.play_sfx("select")
	get_tree().quit()

func _on_controls_pressed() -> void:
	SoundManager.play_sfx("select")
	get_tree().change_scene_to_file("res://scenes/ui/controls.tscn")

func on_scene_left():
	SoundManager.stop_sfx("main_menu")

func _on_options_pressed() -> void:
	SoundManager.play_sfx("select")
	var master_bus := AudioServer.get_bus_index("Master")
	var is_muted := AudioServer.is_bus_mute(master_bus)
	AudioServer.set_bus_mute(master_bus, not is_muted)
	_update_mute_button_text()

	
