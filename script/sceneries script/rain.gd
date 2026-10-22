extends GPUParticles2D

func _ready():
	update_weather_visuals()

func _process(delta: float) -> void:
	update_weather_visuals()
		
func update_weather_visuals(): 
		if GameState.weather == "Rain":
			amount = 300
			emitting = true
			visible = true
		elif GameState.weather == "Storm":
			amount = 1000
			emitting = true
			visible = true
		elif GameState.weather == "Cloudy" or GameState.weather == "Sunny":	
			emitting = false
			visible = false
