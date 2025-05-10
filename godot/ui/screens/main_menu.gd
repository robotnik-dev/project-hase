extends Control
class_name UIMainMenu

@export var select_car: Button
@export var start: Button
@export var difficulty: OptionButton

func _ready() -> void:
	start.grab_focus()
	difficulty.item_selected.connect(_on_difficulty_set)
	# one shot signal to begin of main screen
	Signals.emit_difficulty_selected(difficulty.selected)


func _on_difficulty_set(index: int):
	Signals.emit_difficulty_selected(index)
