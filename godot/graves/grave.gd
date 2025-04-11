extends MeshInstance3D
class_name Grave

@onready var label = $Label3D

func setup(spawn_position: Vector3, x_rotation: float, text: String):
	label.text = text
	global_position = spawn_position + position
	global_rotation.x = x_rotation
