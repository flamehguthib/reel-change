extends Control

var scene_path := ""

var dots := 0
var timer := 0.0

func _ready():
	if GameState.next_scene_path.is_empty():
		scene_path = "res://scenes/location/main_scene.tscn"
	else:
		scene_path = GameState.next_scene_path

	GameState.next_scene_path = ""

	ResourceLoader.load_threaded_request(scene_path)

func _process(delta):
	timer += delta

	if timer >= 0.5:
		timer = 0.0
		dots += 1

		if dots > 3:
			dots = 0

		$LoadingLabel.text = "LOADING" + ".".repeat(dots)

	var progress := []
	var status := ResourceLoader.load_threaded_get_status(scene_path, progress)

	if progress.size() > 0:
		var percentage = progress[0] * 100.0
		$LoadingProgress.value = progress[0] * 100.0 * 2
		$ProgressLabel.text = str(int(progress[0] * 100.0 * 2)) + "%"

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed_scene = ResourceLoader.load_threaded_get(scene_path)
		get_tree().change_scene_to_packed(packed_scene)
