extends Button

func _ready() -> void:
	pressed.connect(func(): Signals.emit_back_to_menu_button_pressed())
