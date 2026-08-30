extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameState.TIME_PERIOD.Morning == GameState.current_time_index:
		play("default")
		$Dim_Effect.visible = false
	elif GameState.TIME_PERIOD.Afternoon == GameState.current_time_index:
		play("default")
		$Dim_Effect.visible = false
	elif GameState.TIME_PERIOD.Night == GameState.current_time_index:
		play("night")
		$Dim_Effect.visible = true 
