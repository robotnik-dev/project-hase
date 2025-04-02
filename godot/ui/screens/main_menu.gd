extends Control
class_name UIMainMenu

@export var select_car: Button
@export var start: Button

func _ready() -> void:
	start.grab_focus()
