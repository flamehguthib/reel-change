extends CharacterBody2D

@onready var anim = $"../AnimationPlayer"
var is_skipping := false
const MAIN_SCENE_PATH := "res://scenes/location/main_scene.tscn"

func _ready():
	print("playing animation")
	anim.play("opening_cutscene")
	set_process(false)
	ResourceLoader.load_threaded_request(MAIN_SCENE_PATH, "", true)
	
func _process(_delta: float) -> void:
	if not is_skipping:
		return
		
	var status = ResourceLoader.load_threaded_get_status(MAIN_SCENE_PATH)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(MAIN_SCENE_PATH)
		get_tree().change_scene_to_packed(new_scene)
		set_process(false)

func _input(event: InputEvent) -> void:
	if is_skipping:
		return
	# Allow ESC, Space, or Enter to skip cutscene
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		skip_cutscene()

func skip_cutscene() -> void:
	if is_skipping:
		return
	is_skipping = true
	anim.stop(true)
	
	ResourceLoader.load_threaded_request(MAIN_SCENE_PATH)
	set_process(true)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if not is_skipping:
		get_tree().change_scene_to_file("res://scenes/location/main_scene.tscn")
func _on_skip_button_pressed() -> void:
	skip_cutscene()
