extends Control

func _ready() -> void:
	get_window().content_scale_size = Vector2i(1280, 1080)

func _on_button_pressed() -> void:
	SoundManager.stop_sfx("main_menu")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
