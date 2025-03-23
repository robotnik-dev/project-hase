extends Button

func _ready() -> void:
	pressed.connect(func(): Signals.emit_select_car_button_pressed())
