extends Node
class_name Main

@export var dev_ui: DeveloperUI

@export var ui: Control

@export var wait_after_crash: float = 3.0

## In seconds
@export var wait_until_next_level: float = 2.0
## when on: replays the level as soon as the car hits the finish line.
## when off: plays the next level or prints "no more levels" in case its only
## one level left
@export var replay_first_level: bool = false

@export var conductor: Conductor

@export_subgroup("Level")
## In Order: First item is level 1 and so on.
@export var level_scenes: Array[PackedScene]
## Default car scene at "res://car/car.tscn"
@export var default_car_scene: PackedScene = preload("res://car/car.tscn")

var current_level: Level = null
var current_level_idx = 0
var current_car: Car = null

var main_menu_scene: PackedScene = preload("res://ui/screens/main_menu.tscn")
var main_menu: UIMainMenu
var pause_menu_scene: PackedScene = preload("res://ui/screens/pause_menu.tscn")
var pause_menu: UIPauseMenu
var select_car_menu_scene: PackedScene = preload("res://ui/screens/car_selection.tscn")
var select_car_menu: UICarSelection
var hud_scene: PackedScene = preload("res://ui/hud/hud.tscn")
var hud: HUD
var end_of_game_scene: PackedScene = preload("res://ui/screens/end_of_game.tscn")
var end_of_game: UIEndOfGame
var level_selection_scene: PackedScene = preload("res://ui/screens/level_selection.tscn")
var level_selection: UILevelSelection

var car_crashed: bool = false

func _ready() -> void:
	_connect_signals()
	start_main_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("developer_ui"):
		dev_ui.visible = !dev_ui.visible

func start_main_menu():
	conductor.change_track(-1)
	main_menu = main_menu_scene.instantiate()
	ui.add_child(main_menu)
	
	# ensure game is not paused
	get_tree().paused = false
	
	# removing pause because it should only be inside a level
	if pause_menu:
		pause_menu.queue_free()
		pause_menu = null
	
	if hud:
		hud.queue_free()
		hud = null
	
	if is_instance_valid(current_car):
		current_car.queue_free()
		current_car = null
	
	if is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null
	
	# removing enf of game menu
	if is_instance_valid(end_of_game):
		ui.remove_child(end_of_game)
		end_of_game.queue_free()
		end_of_game = null

func start_level():
	conductor.change_track(current_level_idx)
	car_crashed = false
	
	# removing main menu
	if main_menu:
		ui.remove_child(main_menu)
		main_menu.queue_free()
		main_menu = null
	
	# removing enf of game menu
	if end_of_game:
		ui.remove_child(end_of_game)
		end_of_game.queue_free()
		end_of_game = null
	
	# setup car
	if is_instance_valid(current_car):
		current_car.queue_free()
	current_car = default_car_scene.instantiate()
	add_child(current_car)
	
	# removing HUD
	if hud:
		hud.queue_free()
		hud = null
	
	# adding HUD
	hud = hud_scene.instantiate()
	ui.add_child(hud)
	hud.setup(current_car)
	
	# removing pause first
	if pause_menu:
		ui.remove_child(pause_menu)
		pause_menu.queue_free()
		pause_menu = null
	
	# adding pause menu
	pause_menu = pause_menu_scene.instantiate()
	ui.add_child(pause_menu)
	
	# setup level
	if is_instance_valid(current_level):
		current_level.queue_free()
	
	var scene = level_scenes[current_level_idx]
	current_level = scene.instantiate()
	add_child(current_level, true)
	
	current_car.setup(current_level.start_position, current_level.end_position)

func reload_level():
	start_level()

func next_level():
	if level_scenes.size() <= current_level_idx + 1:
		current_level_idx = 0
		
		# unload level
		current_level.queue_free()
		current_car.queue_free()
		# removing HUD
		if hud:
			hud.queue_free()
			hud = null
		
		# add eog screen
		end_of_game = end_of_game_scene.instantiate()
		ui.add_child(end_of_game)
		return
	else:
		current_level_idx += 1
	Signals.emit_new_level_started(get_current_level_id() + 1)
	start_level()

func get_current_level_id() -> int:
	return current_level_idx

func _connect_signals():
	Signals.connect_start_button_pressed(_on_start_pressed)
	Signals.connect_back_to_menu_button_pressed(start_main_menu)
	Signals.connect_select_car_button_pressed(_on_select_car_button)
	Signals.connect_quit_button_pressed(_on_quit_game)
	Signals.connect_car_crashed(_on_car_crashed)
	Signals.connect_car_finished(_on_car_finished)
	Signals.connect_replay_level_button_pressed(reload_level)
	Signals.connect_replay_level_button_pressed(_on_reload_level_pressed)
	Signals.connect_select_level_button_pressed(_on_select_level_pressed)

func _on_start_pressed():
	Signals.emit_new_level_started(get_current_level_id() + 1)
	start_level()

func _on_select_level_pressed():
	# removing main menu
	if main_menu:
		ui.remove_child(main_menu)
		main_menu.queue_free()
		main_menu = null
	
	# add level selection menu
	level_selection = level_selection_scene.instantiate()
	ui.add_child(level_selection)
	level_selection.selected.connect(_on_level_selected)

func _on_level_selected(idx: int):
	# remove level selection
	if level_selection:
		ui.remove_child(level_selection)
		level_selection.queue_free()
		level_selection = null
	
	current_level_idx = idx
	
	Signals.emit_new_level_started(get_current_level_id() + 1)
	call_deferred("start_level")

func _on_select_car_button():
	# removing main menu
	if main_menu:
		ui.remove_child(main_menu)
		main_menu.queue_free()
		main_menu = null
	
	# removing pause menu
	if pause_menu:
		ui.remove_child(pause_menu)
		pause_menu.queue_free()
		pause_menu = null
	
	# unload level
	if is_instance_valid(current_level):
		current_level.queue_free()
	if is_instance_valid(current_car):
		current_car.queue_free()
	# removing HUD
	if hud:
		hud.queue_free()
		hud = null
	
	# ensure game is not paused
	get_tree().paused = false
	
	select_car_menu = select_car_menu_scene.instantiate()
	ui.add_child(select_car_menu)
	select_car_menu.selected.connect(_on_car_selected)

func _on_car_selected(idx: int):
	# set car scene
	default_car_scene = select_car_menu.cars[idx]
	
	# remove car selection
	if select_car_menu:
		select_car_menu.queue_free()
		select_car_menu = null
	
	# start main menu
	call_deferred("start_main_menu")

func _on_reload_level_pressed():
	reload_level.call_deferred()

func _on_car_crashed(_position: Vector3, _last_poc: Vector3, _abyss: bool):
	car_crashed = true
	create_tween().tween_callback(reload_level).set_delay(wait_after_crash)

func _on_car_finished():
	if car_crashed:
		return
	
	if replay_first_level:
		reload_level()
	else:
		get_tree().create_timer(wait_until_next_level).timeout.connect(next_level)

func _on_quit_game():
	get_tree().quit()
