extends Button

func _ready() -> void:
	pressed.connect(func(): Signals.emit_quit_button_pressed())
