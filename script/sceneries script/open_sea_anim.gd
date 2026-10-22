extends AnimatedSprite2D

func _ready() -> void:
	$Rain_Dim.hide()
	$Storm_Dim.hide()
	$LightningFlash.hide()
	$LightningFlash.set_process(false)
	update_weather_visuals()

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
	update_weather_visuals()
		
func update_weather_visuals(): 
		if GameState.weather == "Rain":
			$Rain_Dim.visible = true
			$Storm_Dim.visible = false
			$LightningFlash.visible = false
			$LightningFlash.set_process(false)
		elif GameState.weather == "Storm":
			$Storm_Dim.visible = true
			$Rain_Dim.visible = false
			$LightningFlash.visible = (GameState.weather == "Storm")
			$LightningFlash.set_process(GameState.weather == "Storm")
		elif GameState.weather == "Cloudy" or GameState.weather == "Sunny":	
			$Rain_Dim.visible = false
			$Storm_Dim.visible = false
			$LightningFlash.visible = false
			$LightningFlash.set_process(false)
