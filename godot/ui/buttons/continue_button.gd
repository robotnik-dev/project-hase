extends Button

func _ready() -> void:
	pressed.connect(func(): Signals.emit_continue_level_button_pressed())
