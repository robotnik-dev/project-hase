extends Node

var graves: Array = []
var grave_scene: PackedScene = preload("res://graves/grave.tscn")

func _ready():
	Signals.connect_car_crashed(_on_car_crashed)
	Signals.connect_new_level_started(_on_new_level)

func _get_funny_text() -> String:
	return ContentLoader.get_grave_texts().pick_random()

func _get_random_number(low: float, high: float) -> float:
	return randf_range(low, high)

func _on_car_crashed(position: Vector3):
	var grave = grave_scene.instantiate() as Grave
	add_child(grave)
	position.x += _get_random_number(1., 5.)
	# TODO: find the y coord that crosses path with the terrain to place the grave on the ground
	grave.setup(position, _get_funny_text())
	graves.append(grave)

func _on_new_level(_id: int):
	for g in graves:
		g.queue_free()
	graves.clear()
