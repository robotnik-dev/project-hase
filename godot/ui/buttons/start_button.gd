extends Button

func _ready() -> void:
	pressed.connect(func(): Signals.emit_start_button_pressed())
