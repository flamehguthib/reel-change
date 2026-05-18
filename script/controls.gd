extends Control

func _on_button_pressed() -> void:
	SoundManager.stop_sfx("main_menu")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
