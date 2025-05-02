extends CPUParticles3D

@export var on_speed_threshold: float = 30.0
@export var off_speed_threshold: float = 10.0

@onready var car: Car = get_parent()

func _physics_process(_delta: float) -> void:
	if car.linear_velocity.z > on_speed_threshold:
		emitting = true
	# hystherese effect
	elif car.linear_velocity.z < off_speed_threshold:
		emitting = false
