extends Control

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
