extends Control
class_name UIPauseMenu

@export var continue_button: Button
@export var cars: CenterContainer

func _ready() -> void:
	Signals.connect_continue_level_button_pressed(toggle_pause)
	Signals.connect_car_crashed(_on_car_crashed)
	Signals.connect_camera_loaded(_on_camera_loaded)
	visible = false
	if GameStats.cars_unlocked > 1:
		cars.show()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
	if visible:
		continue_button.grab_focus()

func _on_car_crashed(_a, _b, _c):
	set_process_unhandled_input(false)

func _on_camera_loaded():
	set_process_unhandled_input(true)
