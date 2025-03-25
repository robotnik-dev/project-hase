extends Control
class_name UIMainMenu

@export var select_car: Button
@export var start: Button

func _ready() -> void:
	# TODO: after selecting car is a thing, 
	#select_car.disabled = true
	#select_car.focus_mode = Control.FOCUS_NONE
	start.grab_focus()
