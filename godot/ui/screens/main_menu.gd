extends Control
class_name UIMainMenu

@export var select_car: Button
@export var start: Button
@export var cars: CenterContainer
@export var level: CenterContainer

func _ready() -> void:
	start.grab_focus()
	
	if GameStats.cars_unlocked > 1:
		cars.show()
	if GameStats.level_completed > 0:
		level.show()
