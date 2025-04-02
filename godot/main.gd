extends Node
class_name Main

@export var ui: Control

## In seconds
@export var wait_until_next_level: float = 2.0
## when on: replays the level as soon as the car hits the finish line.
## when off: plays the next level or prints "no more levels" in case its only
## one level left
@export var replay_first_level: bool = false

@export_subgroup("Level")
## In Order: First item is level 1 and so on.
@export var level_scenes: Array[PackedScene]

var current_level: Level = null
var current_level_idx = 0
var current_car: Car = null
## Default car scene at "res://car/car.tscn"
var car_scene: PackedScene = preload("res://car/car.tscn")

var main_menu_scene: PackedScene = preload("res://ui/screens/main_menu.tscn")
var main_menu: UIMainMenu
var pause_menu_scene: PackedScene = preload("res://ui/screens/pause_menu.tscn")
var pause_menu: UIPauseMenu
var select_car_menu_scene: PackedScene = preload("res://ui/screens/car_selection.tscn")
var select_car_menu: UICarSelection

func _ready() -> void:
	_connect_signals()
	start_main_menu()
	# loading savegame
	SaveGame.load()

func start_main_menu():
	main_menu = main_menu_scene.instantiate()
	ui.add_child(main_menu)
	
	# ensure game is not paused
	get_tree().paused = false
	
	# removing pause because it should only be inside a level
	if pause_menu:
		pause_menu.queue_free()
		pause_menu = null
	
	if select_car_menu:
		select_car_menu.queue_free()
		select_car_menu = null
	
	if current_car:
		current_car.queue_free()
		current_car = null
	
	if current_level:
		current_level.queue_free()
		current_level = null

func start_level():
	# grab selected car from the selection menu
	if select_car_menu:
		car_scene = select_car_menu.cars[select_car_menu.current_idx]
		select_car_menu.queue_free()
		select_car_menu = null
	
	# removing main menu
	if main_menu:
		ui.remove_child(main_menu)
		main_menu.queue_free()
		main_menu = null
	
	# removing pause first
	if pause_menu:
		ui.remove_child(pause_menu)
		pause_menu.queue_free()
		pause_menu = null
	
	# adding pause menu
	pause_menu = pause_menu_scene.instantiate()
	ui.add_child(pause_menu)
	
	# setup car
	if current_car:
		current_car.queue_free()
	current_car = car_scene.instantiate()
	add_child(current_car)
	
	# setup level
	if current_level:
		current_level.queue_free()
	
	var scene = level_scenes[current_level_idx]
	current_level = scene.instantiate()
	add_child(current_level, true)
	
	current_car.setup(current_level.start_position, current_level.end_position)

func reload_level():
	start_level()

func next_level():
	if level_scenes.size() <= current_level_idx + 1:
		# TODO: proper end of game, just first level again for now
		current_level_idx = 0
	else:
		current_level_idx += 1
	start_level()

func get_current_level_id() -> int:
	return current_level_idx

func _connect_signals():
	Signals.connect_start_button_pressed(start_level)
	Signals.connect_back_to_menu_button_pressed(start_main_menu)
	Signals.connect_select_car_button_pressed(_on_select_car_button)
	Signals.connect_quit_button_pressed(_on_quit_game)
	Signals.connect_car_flipped(_on_car_flipped)
	Signals.connect_car_crashed(_on_car_crashed)
	Signals.connect_car_finished(_on_car_finished)
	Signals.connect_replay_level_button_pressed(reload_level)
	Signals.connect_replay_level_button_pressed(_on_reload_level_pressed)

func _on_select_car_button():
	# removing main menu
	if main_menu:
		ui.remove_child(main_menu)
		main_menu.queue_free()
		main_menu = null
	
	select_car_menu = select_car_menu_scene.instantiate()
	ui.add_child(select_car_menu)

func _on_reload_level_pressed():
	reload_level.call_deferred()

func _on_car_crashed(_position: Vector3):
	reload_level()

func _on_car_finished():
	if replay_first_level:
		reload_level()
	else:
		get_tree().create_timer(wait_until_next_level).timeout.connect(next_level)

func _on_car_flipped(direction: StringName, count: int):
	match direction:
		"front":
			print("front flip number " + str(count))
		"back":
			print("back flip number " + str(count))

func _on_quit_game():
	get_tree().quit()
