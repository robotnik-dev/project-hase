extends Control
class_name UIEndOfGame

@export var popup_delay: float = 1.0

@export var back_to_menu: Button

@export var death_value: Label
@export var playtime: Label
@export var cars_unlocked: Label
@export var collectibles: Label
@export var flips: Label

func _ready() -> void:
	back_to_menu.grab_focus()
	var _death_value = GameStats.crashes
	var _playtime = GameStats.playtime
	var _cars_unlocked = GameStats.cars_unlocked
	var _max_cars = GameStats.max_cars
	var _collectibles = GameStats.collected
	var _max_collectible = GameStats.max_collectibles
	var _flips = GameStats.flips
	
	death_value.text = str(_death_value)
	playtime.text = str(_playtime) + " min"
	cars_unlocked.text = str(_cars_unlocked) + " / " + str(_max_cars)
	collectibles.text = str(_collectibles) + " / " + str(_max_collectible)
	flips.text = str(_flips)
