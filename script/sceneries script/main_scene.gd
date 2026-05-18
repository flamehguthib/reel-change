extends Node2D

@export var camera_zoom: Vector2 = Vector2(0.5, 0.5)
@export var map_limits: Rect2 = Rect2(0, 0, 6120, 6120)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Spawn.setup_player_camera(camera_zoom, map_limits)
	SoundManager.play_sfx("beach")
	tree_exiting.connect(on_scene_left)
	
func on_scene_left():
	SoundManager.stop_sfx("beach")
	SoundManager.stop_sfx("boat_idle")
	SoundManager.stop_sfx("boat_move")
