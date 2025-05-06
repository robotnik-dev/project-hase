extends CheckButton

func _ready() -> void:
	var conductor = get_tree().get_first_node_in_group("Conductor") as Conductor
	if !conductor.main_track_playing():
		button_pressed = true
	pressed.connect(func(): Signals.emit_toggle_music_button_pressed())
