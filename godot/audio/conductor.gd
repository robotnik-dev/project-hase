extends Node
class_name Conductor

var mute: bool = false

@export var main_track: FmodEventEmitter3D

func _ready() -> void:
	Signals.connect_toggle_music_button_pressed(_on_toggle_music)
	main_track.play()

func mute_music(_mute: bool):
	if _mute:
		main_track.stop()
	else:
		main_track.play()

func _on_toggle_music():
	mute = !mute
	mute_music(mute)
