extends CharacterBody2D

@onready var anim = $"../AnimationPlayer"
var is_skipping := false

func _ready():
	print("playing animation")
	anim.play("opening_cutscene")

func _input(event: InputEvent) -> void:
	if is_skipping:
		return
	# Allow ESC, Space, or Enter to skip cutscene
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		skip_cutscene()

func skip_cutscene() -> void:
	if is_skipping:
		return
	is_skipping = true
	anim.stop()
	anim.play("fade_out")

func play_anim( animation_name ) -> void:
	if not is_skipping:
		anim.play( animation_name )

func stop_anim() -> void:
	anim.stop()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		get_tree().change_scene_to_file("res://scenes/ui/loading_screen.tscn")
		return

	if is_skipping:
		return

	if anim_name == "opening_cutscene":
		anim.play("fade_out")

func _on_skip_button_pressed() -> void:
	skip_cutscene()
