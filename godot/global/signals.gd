extends Node

## Global signal handler to delegate connecting and emitting signals.

## No signal should be connected or emitted directly, instead use the associated
## helper functions. Every function returns all connections currently connected
## to the given signal.

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

## helper function to emit the signal as deferred
func emit_deferred(_signal: Signal) -> Array:
	call_deferred("emit_signal", _signal.get_name())
	return _signal.get_connections()

signal _car_flipped(direction: StringName, count: int)
func connect_car_flipped(callable: Callable) -> Array:
	_car_flipped.connect(callable)
	return _car_flipped.get_connections()
func emit_car_flipped(direction: StringName, count: int) -> Array:
	_car_flipped.emit(direction, count)
	return _car_flipped.get_connections()

signal _collected()
func connect_collected(callable: Callable) -> Array:
	_collected.connect(callable)
	return _collected.get_connections()
func emit_collected(id: int) -> Array:
	_collected.emit(id)
	return _collected.get_connections()

signal _car_crashed
func connect_car_crashed(callable: Callable) -> Array:
	_car_crashed.connect(callable)
	return _car_crashed.get_connections()
func emit_car_crashed() -> Array:
	return emit_deferred(_car_crashed)

signal _car_finished
func connect_car_finished(callable: Callable) -> Array:
	_car_finished.connect(callable)
	return _car_finished.get_connections()
func emit_car_finished() -> Array:
	return emit_deferred(_car_finished)

signal _start_button_pressed
func connect_start_button_pressed(callable: Callable) -> Array:
	_start_button_pressed.connect(callable)
	return _start_button_pressed.get_connections()
func emit_start_button_pressed() -> Array:
	return emit_deferred(_start_button_pressed)

signal _select_car_button_pressed
func connect_select_car_button_pressed(callable: Callable) -> Array:
	_select_car_button_pressed.connect(callable)
	return _select_car_button_pressed.get_connections()
func emit_select_car_button_pressed() -> Array:
	return emit_deferred(_select_car_button_pressed)

signal _replay_level_button_pressed
func connect_replay_level_button_pressed(callable: Callable) -> Array:
	_replay_level_button_pressed.connect(callable)
	return _replay_level_button_pressed.get_connections()
func emit_replay_level_button_pressed() -> Array:
	return emit_deferred(_replay_level_button_pressed)

signal _continue_level_button_pressed
func connect_continue_level_button_pressed(callable: Callable) -> Array:
	_continue_level_button_pressed.connect(callable)
	return _continue_level_button_pressed.get_connections()
func emit_continue_level_button_pressed() -> Array:
	return emit_deferred(_continue_level_button_pressed)

signal _back_to_menu_button_pressed
func connect_back_to_menu_button_pressed(callable: Callable) -> Array:
	_back_to_menu_button_pressed.connect(callable)
	return _back_to_menu_button_pressed.get_connections()
func emit_back_to_menu_button_pressed() -> Array:
	return emit_deferred(_back_to_menu_button_pressed)

signal _toggle_fullscreen_button_pressed
func connect_toggle_fullscreen_button_pressed(callable: Callable) -> Array:
	_toggle_fullscreen_button_pressed.connect(callable)
	return _toggle_fullscreen_button_pressed.get_connections()
func emit_toggle_fullscreen_button_pressed() -> Array:
	return emit_deferred(_toggle_fullscreen_button_pressed)

signal _toggle_music_button_pressed
func connect_toggle_music_button_pressed(callable: Callable) -> Array:
	_toggle_music_button_pressed.connect(callable)
	return _toggle_music_button_pressed.get_connections()
func emit_toggle_music_button_pressed() -> Array:
	return emit_deferred(_toggle_music_button_pressed)

signal _quit_button_pressed
func connect_quit_button_pressed(callable: Callable) -> Array:
	_quit_button_pressed.connect(callable)
	return _quit_button_pressed.get_connections()
func emit_quit_button_pressed() -> Array:
	return emit_deferred(_quit_button_pressed)
