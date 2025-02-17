extends Node

@export var start: Node3D

var car_scene: PackedScene = preload("res://car/car.tscn")

var car: Car

func _ready() -> void:
	start_level()


func start_level() -> void:
	car = car_scene.instantiate() as Car
	add_child(car)
	car.global_position = start.global_position
	car.crashed.connect(_on_car_crashed)

func _on_car_crashed() -> void:
	car.crashed.disconnect(_on_car_crashed)
	car.queue_free()
	start_level()
