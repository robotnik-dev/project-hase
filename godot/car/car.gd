extends Car


var tilt_direction = 0
var drive_direction = 0

func _get_forward_input() -> float:
	return drive_direction

func _get_tilt_input() -> float:
	return tilt_direction

# Happens once per click/hold
func _on_player_input_drive_forward_pressed() -> void:
	drive_direction = 1.0


func _on_player_input_drive_forward_released() -> void:
	drive_direction = 0.0


func _on_player_input_drive_backward_pressed() -> void:
	drive_direction = -1.0


func _on_player_input_drive_backward_released() -> void:
	drive_direction = 0.0


func _on_player_input_tilt_backward_pressed() -> void:
	tilt_direction = -1.0


func _on_player_input_tilt_backward_released() -> void:
	tilt_direction = 0.0


func _on_player_input_tilt_forward_pressed() -> void:
	tilt_direction = 1.0


func _on_player_input_tilt_forward_released() -> void:
	tilt_direction = 0.0


func _on_crashed() -> void:
	print("CRASH")
