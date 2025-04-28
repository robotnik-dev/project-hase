extends Control
class_name UIEndOfGame

@export var popup_delay: float = 1.0

@export var back_to_menu: Button

@export var death_value: Label
@export var playtime: Label
@export var cars_unlocked: Label
@export var collectibles: Label

func _ready() -> void:
	back_to_menu.grab_focus()

func setup(_death_value: int, _playtime: float, _cars_unlocked: int, _max_cars: int, _collectibles: int, _max_collectible):
	death_value.text = str(_death_value)
	playtime.text = str(_playtime) + " min"
	cars_unlocked.text = str(_cars_unlocked) + " / " + str(_max_cars)
	collectibles.text = str(_collectibles) + " / " + str(_max_collectible)
