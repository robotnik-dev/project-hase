extends Button

func _ready() -> void:
	pressed.connect(func(): Signals.call_deferred("emit_start_button_pressed"))
