extends Node
class_name Conductor

@export var music_player: AudioStreamPlayer

@export var desert_track: AudioStreamMP3
@export var jungle_track: AudioStreamMP3

var mute: bool = false

var current_track: int = -1

func _ready() -> void:
	Signals.connect_toggle_music_button_pressed(_on_toggle_music)

## Changes track either to desert track (idx: 0) or jungle (idx: 1) or nothing (idx: -1)
func change_track(idx: int):
	if idx == -1:
		# stop all tracks
		music_player.stop()
		music_player.stream = null
	elif idx == 0 and idx != current_track:
		music_player.stream = desert_track
		music_player.play()
	elif idx == 1 and idx != current_track:
		music_player.stream = jungle_track
		music_player.play()
	current_track = idx
	music_player.stream_paused = mute

func mute_music(_mute: bool):
	mute = _mute
	music_player.stream_paused = mute

func _on_toggle_music():
	mute_music(!mute)
