extends Sprite2D

get_tree()


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$FishermanIdle.frame += 1;

func idle():
	pass
