extends GPUParticles3D

@export var speed_threshold: float = 10.0

@onready var car: Car = get_parent()

func _physics_process(delta: float) -> void:
	if car.linear_velocity.length() > speed_threshold and car.is_on_floor():
		emitting = true
	else:
		emitting = false
