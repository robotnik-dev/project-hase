extends Node3D
class_name Grave

@export var width: float
@export var height: float

@onready var label = $Mesh/Label3D
@onready var start_pos: Vector3 = position

var used: bool = false

func setup(spawn_position: Vector3, x_rotation: float, text: String):
	label.text = text
	global_position = spawn_position + start_pos
	global_rotation.x = x_rotation

func get_angle() -> float:
	return global_rotation.x
