extends Node

@export var start: Node3D

var car_scene = preload("res://car/car.tscn")

var car: Car

func _ready() -> void:
	start_level()


func start_level() -> void:
	if car:
		car.queue_free()
	car = car_scene.instantiate()
	add_child(car)
	car.global_position = start.global_position
	car.crashed.connect(_on_car_crashed)

func _on_car_crashed() -> void:
	start_level()

func _on_tree_exiting() -> void:
	print_orphan_nodes()
