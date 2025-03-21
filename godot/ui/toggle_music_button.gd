extends CheckButton

func _ready() -> void:
	pressed.connect(func(): Signals.call_deferred("emit_toggle_music_button_pressed"))
