extends Area2D

var fishing_mechanic_scene = preload("res://scenes/fishing_mechanic.tscn")
var fishing_mechanic = null

func _ready() -> void:
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func random_timer():
	var wait_secs = randf_range(1.0, 2.0)
	$Timer.wait_time = wait_secs
	$Timer.start()
	print(wait_secs)
	
func _on_area_entered(area):
	if area.is_in_group("water"):
		random_timer()

func _on_timer_timeout() -> void:
	print("nigga fishing na tayo")
	if fishing_mechanic == null:
		fishing_mechanic = fishing_mechanic_scene.instantiate()
		add_child(fishing_mechanic)
