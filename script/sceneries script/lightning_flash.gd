extends ColorRect

@export_group("Timing Settings")
@export var min_wait_time: float = 2.0   ## Minimum seconds between strikes
@export var max_wait_time: float = 7.0   ## Maximum seconds between strikes
@export var flash_fade_duration: float = 0.2 ## Seconds it takes for a flash to fade out

@export_group("Double Flash (Flicker)")
@export var double_strike_chance: float = 0.45 ## 45% chance to hit a second quick flicker
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color.a = 0.0
	start_lightning_loop()
	
func start_lightning_loop() -> void:
	while is_inside_tree():
		# 1. Wait a random interval before the next strike
		var delay: float = randf_range(min_wait_time, max_wait_time)
		await get_tree().create_timer(delay).timeout

		# 2. First main flash
		await flash_screen(randf_range(0.7, 1.0)) # Random brightness

		# 3. Optional quick second strike (realistic lightning flicker)
		if randf() < double_strike_chance:
			await get_tree().create_timer(randf_range(0.05, 0.12)).timeout
			await flash_screen(randf_range(0.3, 0.6)) # Slightly dim secondary flash
			
			
			
func flash_screen(peak_opacity: float) -> void:
	# Instantly pop to white opacity
	color.a = peak_opacity
	
	# Smoothly fade back down to transparent (Alpha = 0)
	var tween: Tween = create_tween()
	tween.tween_property(self, "color:a", 0.0, flash_fade_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	await tween.finished


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
