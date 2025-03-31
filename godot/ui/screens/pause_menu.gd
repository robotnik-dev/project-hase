extends Control
class_name UIPauseMenu

@export var continue_button: Button

func _ready() -> void:
	Signals.connect_continue_level_button_pressed(toggle_pause)
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
	if visible:
		continue_button.grab_focus()
		#SaveGame.save_game()
