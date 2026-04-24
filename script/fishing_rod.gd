extends AnimatedSprite2D

var fishing_bob_scene = preload("res://scenes/Fisherman/fishing_bob.tscn")
var fishing_bob = null
var fish_bar_scene = preload("res://scenes/Fisherman/fishing_mechanic.tscn")
var fish_bar_instance = null


const FISH_BAR_OFFSET_RIGHT = Vector2(112.0, 18.0)
const FISH_BAR_OFFSET_LEFT = Vector2(-96.0, 18.0)


func _ready() -> void:
	pass # Replace with function body.
	
func _process(_delta: float) -> void:
	pass
	#spawn_bob()
	
func spawn_bob():
	if animation == "fish":
		if fishing_bob == null:
			fishing_bob = fishing_bob_scene.instantiate()
			add_child(fishing_bob)
			fishing_bob.global_position = $FishingRodTip.global_position
			
			
			var fish_detector = fishing_bob.get_node_or_null("Player")
			if fish_detector != null and fish_detector.has_signal("fish_bite"):
				fish_detector.fish_bite.connect(_on_fish_bite)
			if fish_detector != null and fish_detector.has_signal("fish_missed"):
				fish_detector.fish_missed.connect(_on_fish_missed)
				
func spawn_fish_bar():
	if fish_bar_instance == null:
		fish_bar_instance = fish_bar_scene.instantiate()
		add_child(fish_bar_instance)
		fish_bar_instance.z_as_relative = false
		fish_bar_instance.z_index = 100
		update_fish_bar_position()
		var fish_ui = fish_bar_instance.get_node_or_null("Control")
		if fish_ui != null and fish_ui.has_signal("finished"):
			fish_ui.finished.connect(_on_fish_bar_finished)

func update_fish_bar_position() -> void:
	if fish_bar_instance == null or not is_instance_valid(fish_bar_instance):
		return
	# Left and right use slightly different offsets so they visually match.
	if $Player.flip_h:
		fish_bar_instance.position = FISH_BAR_OFFSET_LEFT
	else:
		fish_bar_instance.position = FISH_BAR_OFFSET_RIGHT

func kill_fish_bar():
	if fish_bar_instance != null and is_instance_valid(fish_bar_instance):
		fish_bar_instance.queue_free()
		fish_bar_instance = null

func _on_fish_bar_finished(caught: bool) -> void:
	fish_bar_instance = null
	if caught:
		GameState.add_fish_to_inventory(randi_range(80, 150))
	if animation == "fish":
		$Player.play("hook")
		$FishingRod.play("hook")

func _on_fish_bite() -> void:
	print("Fish bite triggered")
	if animation == "fish" and fish_bar_instance == null:
		spawn_fish_bar()

func _on_fish_missed() -> void:
	print("Fish escaped before minigame")
	if animation == "fish" and fish_bar_instance == null:
		$Player.play("hook")
		$FishingRod.play("hook")
		
