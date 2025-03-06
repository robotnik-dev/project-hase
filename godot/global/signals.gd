extends Node

## Global signal handler to delegate connecting and emitting signals.

## No signal should be connected or emitted directly, instead use the associated
## helper functions. Every function returns all connections currently connected
## to the given signal.

signal _car_flipped(direction: StringName, count: int)
func connect_car_flipped(callable: Callable) -> Array:
	_car_flipped.connect(callable)
	return _car_flipped.get_connections()
func emit_car_flipped(direction: StringName, count: int) -> Array:
	_car_flipped.emit(direction, count)
	return _car_flipped.get_connections()

signal _car_crashed
func connect_car_crashed(callable: Callable) -> Array:
	_car_crashed.connect(callable)
	return _car_crashed.get_connections()
func emit_car_crashed() -> Array:
	_car_crashed.emit()
	return _car_crashed.get_connections()

signal _car_finished
func connect_car_finished(callable: Callable) -> Array:
	_car_finished.connect(callable)
	return _car_finished.get_connections()
func emit_car_finished() -> Array:
	_car_finished.emit()
	return _car_finished.get_connections()

signal _replay_level_button_pressed
func connect_replay_level_button_pressed(callable: Callable) -> Array:
	_replay_level_button_pressed.connect(callable)
	return _replay_level_button_pressed.get_connections()
func emit_replay_level_button_pressed() -> Array:
	_replay_level_button_pressed.emit()
	return _replay_level_button_pressed.get_connections()
