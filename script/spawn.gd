extends Marker2D

var fisherman = null
var fisherman_scene = preload("res://scenes/Fisherman/fisherman.tscn")

func setup_player_camera(zoom_setting: Vector2, limit: Rect2):
	if fisherman == null:
		fisherman = fisherman_scene.instantiate()
		get_tree().current_scene.call_deferred("add_child", fisherman)
		fisherman.global_position = %Spawn.global_position
		var cam = fisherman.get_node("%Camera2D")

		# Adaptive zoom: scale base zoom to fit viewport height
		var base_zoom := zoom_setting
		var vp_size := get_viewport().get_visible_rect().size
		if vp_size.y > 0:
			var target_zoom_y := base_zoom.y * (vp_size.y / 1080.0)  # 1080 is design height
			cam.zoom = Vector2(target_zoom_y, target_zoom_y)
		else:
			cam.zoom = base_zoom

		cam.limit_left = limit.position.x
		cam.limit_top = limit.position.y
		cam.limit_bottom = limit.size.y
		cam.limit_right = limit.size.x

		
		
