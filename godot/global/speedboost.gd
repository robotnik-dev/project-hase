extends Node

signal boost_ready

var flip_detection: FlipDetection
var is_boost_ready: bool = false
var boost_progress: float = 0.0

var car: Car

func _ready() -> void:
	Signals.connect_camera_loaded(_on_camera_loaded)
	Signals.connect_car_crashed(_on_car_crashed)
	Signals.connect_car_flipped(_on_car_flipped)

func _process(_delta):
	if not flip_detection:
		return
	
	if is_boost_ready:
		return
	
	_increase_through_air_time()

## any caller using this function can reset,
## so that the boost ist ready again
func used():
	is_boost_ready = false
	boost_progress = 0.0

func _increase_through_air_time():
	if not flip_detection.is_on_floor():
		boost_progress = clampf(boost_progress + car.boost_fill_speed / 1000.0, 0.0, 1.0)
	
	if boost_progress >= 1.0:
		boost_progress = 1.0
		is_boost_ready = true
		boost_ready.emit()

func _on_car_flipped(_direction: StringName, _count: int):
	boost_progress = 1.0

func _on_camera_loaded():
	call_deferred("set_process", true)
	create_tween().tween_callback(_set_flip_detection).set_delay(0.2)
	boost_progress = 0.0

func _on_car_crashed(_pos, _last_poc, _abyss):
	call_deferred("set_process", false)
	boost_progress = 0.0
	is_boost_ready = false

func _set_flip_detection():
	flip_detection = get_tree().get_first_node_in_group("FlipDetection")
	car = flip_detection.get_parent()
