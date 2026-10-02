extends GPUParticles2D

func _ready():
	GameState.weather_change.connect(on_weather_change)
	
func on_weather_change(weather):
	if weather == "Rain":
		amount = 300
		emitting = true
		visible = true
		
	elif weather == "Storm":
		amount = 1000
		emitting = true
		visible = true
		
	else:
		emitting = false
		visible = false
