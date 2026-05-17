extends Node2D

@export var camera_zoom: Vector2 = Vector2(0.7, 0.7)
@export var map_limits: Rect2 = Rect2(0, 0, 6500, 2150)

func _ready() -> void:
	%Boat.setup_boat_camera(camera_zoom, map_limits)
