extends Marker2D

var fisherman = null
var fisherman_scene = preload("res://scenes/Fisherman/fisherman.tscn")

func setup_player_camera(zoom_setting: Vector2, limit: Rect2):
	if fisherman == null:
		fisherman = fisherman_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child", fisherman)
		fisherman.global_position = %Spawn.global_position
		var cam = fisherman.get_node("%Camera2D")
		
		cam.zoom = zoom_setting
		cam.limit_left = limit.position.x
		cam.limit_top = limit.position.y
		cam.limit_bottom = limit.size.y
		cam.limit_right = limit.size.x

		
		
