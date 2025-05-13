extends Button

func _on_pressed() -> void:
	Signals.emit_select_level_button_pressed()
