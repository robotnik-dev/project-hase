extends VehicleBody3D

@export_range(1.0, 100.0, 0.1) var max_speed: float = 50.0
@export_range(0.1, 1.0, 0.01) var acceleration: float = 0.85
@export_range(0.1, 1.0, 0.01) var deceleration: float = 0.5
@export_range(0.1, 1.0, 0.01) var tilt_speed: float = 0.5

var tilt_direction = 0
var drive_direction = 0


func _physics_process(delta: float) -> void:
	var torque = 1000 * tilt_speed * tilt_direction
	apply_torque(Vector3(torque, 0,0))
	
	var current_enginge_force = engine_force
	var current_brake = brake
	if abs(linear_velocity.z) < max_speed:
		# we can go faster
		if drive_direction == 0:
			current_enginge_force = 0
			current_brake = 1 * deceleration
		else:
			current_brake = 0
			current_enginge_force = 200 * acceleration * drive_direction
	else:
		# its fast enough
		current_enginge_force -= linear_velocity.z * 0.05
	
	engine_force = current_enginge_force
	brake = current_brake


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
