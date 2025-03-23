extends CheckButton

func _ready() -> void:
	pressed.connect(func(): Signals.emit_toggle_music_button_pressed())
