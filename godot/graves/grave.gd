extends Sprite3D
class_name Grave

@onready var label = $Label3D

func setup(spawn_position: Vector3, text: String):
	label.text = text
	global_position = spawn_position
