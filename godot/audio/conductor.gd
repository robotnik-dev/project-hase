extends Node
class_name Conductor

var mute: bool = false

@export var main_track: FmodEventEmitter3D

func _ready() -> void:
	Signals.connect_toggle_music_button_pressed(_on_toggle_music)
	FmodServer.mute_all_events()

func play_main_track():
	main_track.play()
	FmodServer.unmute_all_events()

func main_track_playing() -> bool:
	return !mute

func mute_music(_mute: bool):
	if _mute:
		FmodServer.mute_all_events()
	else:
		FmodServer.unmute_all_events()

func _on_toggle_music():
	mute = !mute
	mute_music(mute)
