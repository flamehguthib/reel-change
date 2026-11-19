
extends Control

@onready var credits_content: VBoxContainer = $CreditsContent

@export var scroll_duration: float = 20.0
@export_file("*.tscn") var main_menu_scene_path: String = "res://scenes/ui/main_menu.tscn"


func _ready() -> void:
	# Hide credits to prevent them from flashing at the top
	credits_content.hide()

	# Wait for UI containers to calculate their sizes
	await get_tree().process_frame
	await get_tree().process_frame

	var screen_height = get_viewport_rect().size.y
	var screen_width = get_viewport_rect().size.x

	# Set credits below the visible screen
	credits_content.position = Vector2(0, screen_height)
	credits_content.size = Vector2(
		screen_width,
		credits_content.get_combined_minimum_size().y
	)

	# Make children expand horizontally
	for child in credits_content.get_children():
		if child is Control:
			child.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Reveal credits only after positioning them
	credits_content.show()

	# Start scrolling upward
	var tween = create_tween()

	tween.tween_property(
		credits_content,
		"position:y",
		-credits_content.size.y,
		scroll_duration
	).set_trans(Tween.TRANS_LINEAR)

	# Wait until credits finish scrolling
	await tween.finished

	# Return to main menu
	get_tree().change_scene_to_file(main_menu_scene_path)
