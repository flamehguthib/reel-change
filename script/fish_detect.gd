extends Area2D

signal fish_bite
signal fish_missed

var bite_triggered := false
const BITE_CHANCE := 0.75

func _ready() -> void:
	randomize()
	random_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func random_timer():
	if bite_triggered:
		return
	var wait_secs = randf_range(5.0, 10.0)
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
