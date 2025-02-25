extends Node

@export_subgroup("Level")
## In Order: First item is level 1 and so on.
@export var level_scenes: Array[PackedScene]

## In seconds
@export var wait_until_next_level: float = 2.0

var current_level: Level = null
var current_level_idx = 0
var current_car: Car = null
## Default car scene at "res://car/car.tscn"
var path_to_car_scene: String = "res://car/car.tscn"

func _ready() -> void:
	# TODO: inject car scene through UI or different method later
	_on_car_selected("res://car/car.tscn")
	
	start_level()

func start_level():
	# setup car
	if current_car:
		current_car.queue_free()
	var car_scene = load(path_to_car_scene) as PackedScene
	current_car = car_scene.instantiate()
	if !current_car.finish.is_connected(_on_car_finish):
		current_car.finish.connect(_on_car_finish)
	if !current_car.crashed.is_connected(_on_car_crashed):
		current_car.crashed.connect(_on_car_crashed)
	add_child(current_car)
	
	# setup level
	if current_level:
		current_level.queue_free()
	
	var scene = level_scenes[current_level_idx]
	current_level = scene.instantiate()
	if !current_level.start_position_selected.is_connected(_on_level_start_pos_set):
		current_level.start_position_selected.connect(_on_level_start_pos_set)
	if !current_level.end_position_selected.is_connected(_on_level_end_pos_set):
		current_level.end_position_selected.connect(_on_level_end_pos_set)
	add_child(current_level)

func reload_level():
	start_level()

func next_level():
	if level_scenes.size() <= current_level_idx + 1:
		print("no more levels")
		return
	current_level_idx += 1
	start_level()

func _on_level_start_pos_set(pos: Vector3):
	current_car.global_position = pos

func _on_level_end_pos_set(pos: Vector3):
	current_car.set_end_position(pos)

func _on_car_selected(path_to_scene: String):
	path_to_car_scene = path_to_scene

func _on_car_crashed():
	reload_level()

func _on_car_finish():
	get_tree().create_timer(wait_until_next_level).timeout.connect(next_level)
