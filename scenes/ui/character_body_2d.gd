extends CharacterBody2D

@onready var anim = $"../AnimationPlayer"

func _ready():
	print("playing animation")
	anim.play("opening_cutscene")
	
func play_anim( animation_name ) -> void:
	anim.play( animation_name )
	
func stop_anim() -> void:
	anim.stop()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scenes/location/main_scene.tscn")
