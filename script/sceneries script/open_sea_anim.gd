extends AnimatedSprite2D

func _process(_delta: float) -> void:
	if GameState.TIME_PERIOD.Morning == GameState.current_time_index:
		play("morning")
		$Dim_Effect.visible = false
	elif GameState.TIME_PERIOD.Afternoon == GameState.current_time_index:
		play("afternoon")
		$Dim_Effect.visible = false
	elif GameState.TIME_PERIOD.Night == GameState.current_time_index:
		play("night")
		$Dim_Effect.visible = true 
		
	if GameState.weather == "Rain":
		$Rain_Dim.visible = true
	elif GameState.weather == "Storm":
		$Storm_Dim.visible = true
	elif GameState.weather == "Cloudy" or "Sunny":	
		$Rain_Dim.visible = false
		$Storm_Dim.visible = false
