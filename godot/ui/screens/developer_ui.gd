extends Control
class_name DeveloperUI

@export var front_progress: ProgressBar
@export var back_progress: ProgressBar

var flip_detection: FlipDetection

func _ready() -> void:
	hide()
	Signals.connect_camera_loaded(_on_camera_loaded)

func _process(_delta):
	if not flip_detection:
		return
	
	front_progress.value = flip_detection.front_flip_progress
	back_progress.value = flip_detection.back_flip_progress

func _on_camera_loaded():
	create_tween().tween_callback(_set_flip_detection).set_delay(0.2)

func _set_flip_detection():
	flip_detection = get_tree().get_first_node_in_group("FlipDetection")

func _on_replay_level_button_pressed() -> void:
	Signals.emit_replay_level_button_pressed()
