extends Control
class_name DeveloperUI

func _ready() -> void:
	if OS.has_feature("release"):
		hide()


func _on_replay_level_button_pressed() -> void:
	Signals.emit_replay_level_button_pressed()
