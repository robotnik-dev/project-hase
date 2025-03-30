extends Node
class_name Conductor

@export var music_player: AudioStreamPlayer

var mute: bool = false

func _ready() -> void:
	Signals.connect_toggle_music_button_pressed(_on_toggle_music)

func mute_music(_mute: bool):
	music_player.stream_paused = _mute

func _on_toggle_music():
	mute = !mute
	mute_music(mute)
