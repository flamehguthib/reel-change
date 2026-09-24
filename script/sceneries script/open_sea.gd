extends Node2D

@export var camera_zoom: Vector2 = Vector2(0.80, 0.8000)





















































































































@export var map_limits: Rect2 = Rect2(0, 0, 6500, 2150)

@onready var weather_overlay: ColorRect = $WeatherOverlay

func _ready() -> void:
	%Boat.setup_boat_camera(camera_zoom, map_limits)
	SoundManager.play_sfx("sea")
	SoundManager.play_sfx("game_theme")
	tree_exiting.connect(on_scene_left)
	
	# Configure weather overlay with CanvasItemMaterial set to MULTIPLY blend mode.
	# MULTIPLY mode darkens baked-in highlights (like the baked sun in background assets).
	if weather_overlay != null:
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
		weather_overlay.material = mat

func _process(_delta: float) -> void:
	update_weather_overlay()

func update_weather_overlay() -> void:
	if weather_overlay == null:
		return


	# Weather modifier (Multiply further for stormy/rainy darkness)
	var _weather_mod := Color(1.0, 1.0, 1.0, 1.0)
	match GameState.weather:
		GameState.WEATHER_CLOUDY:
			_weather_mod = Color(0.8, 0.82, 0.88, 1.0)
		GameState.WEATHER_RAIN:
			_weather_mod = Color(0.55, 0.6, 0.75, 1.0)
		GameState.WEATHER_STORM:
			_weather_mod = Color(0.3, 0.32, 0.45, 1.0)


func on_scene_left():
	SoundManager.stop_sfx("sea")
	SoundManager.stop_sfx("game_theme")
	SoundManager.stop_sfx("boat_idle")
	SoundManager.stop_sfx("boat_move")
