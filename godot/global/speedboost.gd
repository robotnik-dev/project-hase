extends Node

signal boost_ready

const FILL_SPEED: float = 0.01

var flip_detection: FlipDetection
var is_boost_ready: bool = false
var boost_progress: float = 0.0

func _ready() -> void:
	Signals.connect_camera_loaded(_on_camera_loaded)
	Signals.connect_car_crashed(_on_car_crashed)

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

func _increase_through_air_time():
	if not flip_detection.is_on_floor():
		boost_progress = clampf(boost_progress + FILL_SPEED, 0.0, 1.0)
	
	if boost_progress >= 1.0:
		boost_progress = 0.0
		is_boost_ready = true
		boost_ready.emit()

func _on_camera_loaded():
	create_tween().tween_callback(_set_flip_detection).set_delay(0.2)

func _on_car_crashed(_pos):
	boost_progress = 0.0
	is_boost_ready = false

func _set_flip_detection():
	flip_detection = get_tree().get_first_node_in_group("FlipDetection")
