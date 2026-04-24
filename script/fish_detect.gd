extends Area2D

signal fish_bite
signal fish_missed

var bite_triggered := false
const BITE_CHANCE := 0.75

func _ready() -> void:
	print(get_path())	
	randomize()
	random_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func lose_fish():
	var label = %FishStatus
	label.text = "Fish got away before biting"
	label.modulate.a = 0  # Start transparent
	label.scale = Vector2(0.5, 0.5) # Start small
	label.show()
	
	var tween = create_tween()
	# Fade in and grow at the same time
	tween.tween_property(label, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(label, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK)

func random_timer():
	if bite_triggered:
		return
	var wait_secs = randf_range(2.0, 4.0)
	$Timer.wait_time = wait_secs
	$Timer.start()
	print("Fish bite in %.2fs" % wait_secs)
	
func _on_area_entered(area):
	if area.is_in_group("water") and not bite_triggered:
		random_timer()

func _on_timer_timeout() -> void:
	if bite_triggered:
		return
	bite_triggered = true
	if randf() <= BITE_CHANCE:
		print("Fish bite now")
		emit_signal("fish_bite")
	else:
		print("Fish got away before biting")
		emit_signal("fish_missed")
	$Timer.stop()
