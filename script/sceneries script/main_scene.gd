extends Node2D

@export var camera_zoom: Vector2 = Vector2(0.5, 0.5)
@export var map_limits: Rect2 = Rect2(0, 0, 6120, 6120)

@onready var task_sheet_ui: CanvasLayer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Spawn.setup_player_camera(camera_zoom, map_limits)
	%Boat.setup_boat_camera(Vector2(0.7, 0.7), map_limits)
	SoundManager.play_sfx("beach")
	SoundManager.play_sfx("game_theme")
	tree_exiting.connect(on_scene_left)

	# Setup Task Sheet UI
	_setup_task_sheet_ui()

	# Update camera zoom on window resize
	get_window().size_changed.connect(_on_window_resized)

func _on_window_resized():
	%Spawn.setup_player_camera(camera_zoom, map_limits)
	%Boat.setup_boat_camera(Vector2(0.8, 0.8), map_limits)

func _setup_task_sheet_ui() -> void:
	# Load and instantiate the TaskSheetUI (a view of GameState)
	var task_sheet_scene = preload("res://scenes/ui/TaskSheetUI.tscn")
	if task_sheet_scene:
		task_sheet_ui = task_sheet_scene.instantiate()
		add_child(task_sheet_ui)
		# Add to a group for easy lookup from other code
		task_sheet_ui.add_to_group("TaskSheetUI")

		# Payment + goal progress now live inside GameState (wallet),
		# so this scene only reacts to the goal being claimed.
		if task_sheet_ui.has_signal("goal_claimed"):
			task_sheet_ui.goal_claimed.connect(_on_goal_claimed)

		print("TaskSheetUI initialized")
	else:
		push_error("Failed to load TaskSheetUI scene")

func _on_goal_claimed() -> void:
	print("Goal claimed! Player has saved ₱%d" % GameState.money_goal)
	
func on_scene_left():
	SoundManager.stop_sfx("beach")
	SoundManager.stop_sfx("game_theme")
	SoundManager.stop_sfx("boat_idle")
	SoundManager.stop_sfx("boat_move")


func _on_tree_exiting() -> void:
# Cleanly disable all weather overlays before this scene unloads
	if has_node("Rain_Dim"):
		$Rain_Dim.visible = false
	if has_node("Storm_Dim"):
		$Storm_Dim.visible = false
	if has_node("LightningFlash"):
		$LightningFlash.stop_lightning() # Kills ongoing tweens


func _on_home_tree_exiting() -> void:
	# Cleanly disable all weather overlays before this scene unloads
	if has_node("Rain_Dim"):
		$Rain_Dim.visible = false
	if has_node("Storm_Dim"):
		$Storm_Dim.visible = false
	if has_node("LightningFlash"):
		$LightningFlash.stop_lightning() # Kills ongoing tweens
