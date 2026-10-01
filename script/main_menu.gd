extends Control

func _ready():
	SoundManager.play_sfx("main_menu")
	

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
	# Get the index of the Master bus
	var master_bus := AudioServer.get_bus_index("Master")
	# Toggle mute (useful for Mute Buttons)
	var is_muted := AudioServer.is_bus_mute(master_bus)
# Mute all audio
	if not is_muted:
		AudioServer.set_bus_mute(master_bus, true)
	if is_muted:
# Unmute all audio
		AudioServer.set_bus_mute(master_bus, false)

	
