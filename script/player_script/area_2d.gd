extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Port"):
		SoundManager.play_sfx("walk_on_port")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Port"):
		SoundManager.stop_sfx("walk_on_port")
