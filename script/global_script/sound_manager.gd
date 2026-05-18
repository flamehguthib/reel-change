extends Node

const SFX = {
	"walk": preload("res://assets/sfx/walk.mp3"),
	"walk_on_port": preload("res://assets/sfx/walking_on_port.mp3"),
	"fish": preload("res://assets/sfx/fishing_mechanic_reel.mp3"),
	"cast": preload("res://assets/sfx/cast.mp3"),
	"boat_move": preload("res://assets/sfx/boat_moving.mp3"),
	"boat_idle": preload("res://assets/sfx/boat_idle.mp3"),
	"select": preload("res://assets/sfx/select.mp3"),
	"alert": preload("res://assets/sfx/alert.wav"),
	#background
	"sea": preload("res://assets/sfx/sea_waves.mp3"),
	"beach": preload("res://assets/sfx/beach.mp3"),
	#music
	"main_menu": preload("res://assets/sfx/main_menu.mp3"),
}

var active_sfx: Dictionary = {}

func play_sfx(sound_name):
	if not SFX.has(sound_name):
		print("sound does not exist bruh")
		return
	
	var sfx_player = AudioStreamPlayer.new()
	if sound_name == "boat_move":
		sfx_player.volume_db = -15.0
	if sound_name == "sea":
		sfx_player.volume_db = -15.0
	if sound_name == "beach":
		sfx_player.volume_db = -15
	if sound_name == "main_menu":
		sfx_player.volume_db = -15
		
	sfx_player.stream = SFX[sound_name]
	add_child(sfx_player)
	
	if not active_sfx.has(sound_name):
		active_sfx[sound_name] = []
	active_sfx[sound_name].append(sfx_player)
	
	sfx_player.finished.connect(func():
		if active_sfx.has(sound_name):
			active_sfx[sound_name].erase(sfx_player)
			if active_sfx[sound_name].is_empty():
				active_sfx.erase(sound_name)
		sfx_player.queue_free()
	)
	sfx_player.play()
	
func stop_sfx(sound_name):
	if active_sfx.has(sound_name):
		# Create a copy of the array to avoid mutation bugs while iterating
		var players_to_stop = active_sfx[sound_name].duplicate()
		
		for player in players_to_stop:
			if is_instance_valid(player):
				player.stop()
				player.queue_free() # Safely remove from scene tree
				
		# Remove the sound entry entirely from our tracking dictionary
		active_sfx.erase(sound_name)
	
func is_sfx_playing(sound_name: String) -> bool:
	if active_sfx.has(sound_name) and not active_sfx[sound_name].is_empty():
		# Double-check that the instance hasn't been corrupted or freed
		return is_instance_valid(active_sfx[sound_name][0])
	return false
