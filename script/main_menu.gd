extends Control

func _ready():
	SoundManager.play_sfx("main_menu")
	

func _on_play_pressed() -> void:
	SoundManager.play_sfx("select")
	tree_exiting.connect(on_scene_left)
	get_tree().change_scene_to_file("res://scenes/location/main_scene.tscn"	)

func _on_exit_pressed() -> void:
	SoundManager.play_sfx("select")
	get_tree().quit()

func _on_controls_pressed() -> void:
	SoundManager.play_sfx("select")
	get_tree().change_scene_to_file("res://scenes/ui/controls.tscn")

func on_scene_left():
	SoundManager.stop_sfx("main_menu")
