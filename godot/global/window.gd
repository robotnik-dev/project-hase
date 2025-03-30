extends Node

var fullscreen: bool = false

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	Signals.connect_toggle_fullscreen_button_pressed(_on_toggle_fullscreen)

func set_fullscreen(on: bool):
	if on:
		get_viewport().get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_viewport().get_window().mode = Window.MODE_WINDOWED

func _on_toggle_fullscreen():
	fullscreen = !fullscreen
	set_fullscreen(fullscreen)
