extends Node
class_name GraveDigger

# TODO: list of fun qoutes for the graves

## Saved with the position as the key
var graves: Dictionary = {}
var grave_scene: PackedScene = preload("res://graves/grave.tscn")

func _ready():
	Signals.connect_car_crashed(_on_car_crashed)

func _get_funny_text() -> String:
	# TODO:
	return "you're not dead to me, you're just dead"

func _get_random_number(low: float, high: float) -> float:
	return randf_range(low, high)

func _on_car_crashed(position: Vector3):
	var grave = grave_scene.instantiate() as Grave
	add_child(grave)
	position.x += _get_random_number(1., 5.)
	# TODO: find the y coord that crosses path with the terrain to place the grave on the ground
	grave.setup(position, _get_funny_text())
	graves[position] = grave
