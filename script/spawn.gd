extends Marker2D

var fisherman = null
var fisherman_scene = preload("res://scenes/Fisherman/fisherman.tscn")

func _ready() -> void:
	if fisherman == null:
		fisherman = fisherman_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child", fisherman)
		fisherman.global_position = %Spawn.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
