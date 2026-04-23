extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var rect = $ColorRect

func transition_to_cutscene():
	get_tree().change_scene_to_file("res://scenes/ui/transition_layer.tscn")
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	
	animation_player.play("fade_from_black")
	get_tree().change_scene_to_file("res://scenes/location/main_scene.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rect.self_modulate.a = 0
