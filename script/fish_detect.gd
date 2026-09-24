extends Area2D

signal fish_bite
signal fish_missed

var bite_triggered := false
const BASE_BITE_CHANCE := 0.60

func _ready() -> void:
	randomize()
	random_timer()

func get_bite_chance() -> float:
	var chance := BASE_BITE_CHANCE
	if GameState.active_bait == "hipon":
		chance += 0.25
	elif GameState.active_bait == "tahong":
		chance += 0.35
	elif GameState.has_bait:
		chance += 0.20
	chance *= GameState.get_weather_bite_multiplier()
	return clamp(chance, 0.05, 0.95)

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
	if randf() <= get_bite_chance():
		print("Fish bite now")
		emit_signal("fish_bite")
	else:
		print("Fish got away before biting")
		emit_signal("fish_missed")
	$Timer.stop()
