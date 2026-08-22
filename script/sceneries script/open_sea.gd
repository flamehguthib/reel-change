extends Node2D

@export var camera_zoom: Vector2 = Vector2(0.95, 0.95)
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

	var time_val := GameState.current_time
	var time_multiply := Color(1.0, 1.0, 1.0, 1.0) # Full daylight (6:00 to 17:00)

	# Smooth daylight/sunset/night transitions via MULTIPLY color mode
	if time_val >= 5.0 and time_val < 7.0:
		# Sunrise (Madaling Araw) - Warm rosy golden tint
		var factor := (time_val - 5.0) / 2.0
		time_multiply = Color(0.85, 0.75, 0.6, 1.0).lerp(Color(1.0, 1.0, 1.0, 1.0), factor)
	elif time_val >= 17.0 and time_val < 19.0:
		# Sunset (Takipsilim) - Warm amber sunset tint
		var factor := (time_val - 17.0) / 2.0
		time_multiply = Color(1.0, 1.0, 1.0, 1.0).lerp(Color(0.85, 0.55, 0.35, 1.0), factor)
	elif time_val >= 19.0 or time_val < 5.0:
		# Nighttime (Gabi) - Midnight blue tint that darkens baked sun highlights cleanly
		time_multiply = Color(0.12, 0.15, 0.35, 1.0)

	# Weather modifier (Multiply further for stormy/rainy darkness)
	var weather_mod := Color(1.0, 1.0, 1.0, 1.0)
	match GameState.weather:
		GameState.WEATHER_CLOUDY:
			weather_mod = Color(0.8, 0.82, 0.88, 1.0)
		GameState.WEATHER_RAIN:
			weather_mod = Color(0.55, 0.6, 0.75, 1.0)
		GameState.WEATHER_STORM:
			weather_mod = Color(0.3, 0.32, 0.45, 1.0)

	# Combine night + weather multiply tints
	weather_overlay.color = time_multiply * weather_mod

func on_scene_left():
	SoundManager.stop_sfx("sea")
	SoundManager.stop_sfx("game_theme")
	SoundManager.stop_sfx("boat_idle")
	SoundManager.stop_sfx("boat_move")
