extends Button

func _ready() -> void:
	pressed.connect(func(): Signals.emit_toggle_fullscreen_button_pressed())
