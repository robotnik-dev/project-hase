extends Control
class_name UIBoostButton

@export var button: Button
@export var progress: TextureProgressBar

signal boost_pressed

func _ready():
	button.disabled = true
	Speedboost.boost_ready.connect(_on_boost_ready)
	Speedboost.boost_used.connect(_on_boost_used)
	Signals.connect_car_crashed(_on_car_crashed)
	Signals.connect_camera_loaded(_on_camera_loaded)


func _process(_delta: float) -> void:
	progress.value = Speedboost.boost_progress


func _on_boost_ready():
	button.disabled = false
	progress.material.set("shader_parameter/enabled", true)


func _on_car_crashed(_a,_b,_c):
	button.disabled = true
	progress.material.set("shader_parameter/enabled", false)


func _on_camera_loaded():
	button.disabled = false


func _on_boost_used():
	button.disabled = true
	progress.material.set("shader_parameter/enabled", false)


func _on_button_pressed() -> void:
	if Speedboost.is_boost_ready:
		boost_pressed.emit()
		button.disabled = true
		progress.material.set("shader_parameter/enabled", false)
