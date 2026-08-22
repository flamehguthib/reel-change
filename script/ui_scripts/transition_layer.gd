extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var rect = $ColorRect

func transition_to_cutscene() -> void:
	# The Transition_Manager is a persistent autoload overlay (layer 100).
	# Fade to black, swap the scene, then fade back in.
	rect.visible = true
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://scenes/location/main_scene.tscn")
	animation_player.play("fade_from_black")

func fade_out_in(callback: Callable = Callable()) -> void:
	rect.visible = true
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	if callback.is_valid():
		await callback.call()
	animation_player.play("fade_from_black")
	await animation_player.animation_finished
	rect.visible = false

func _ready() -> void:
	rect.self_modulate.a = 0
	rect.visible = false
