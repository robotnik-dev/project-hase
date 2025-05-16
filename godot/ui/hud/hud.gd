extends Control
class_name HUD

@export var boost_button: UIBoostButton

var car: Car

func setup(_car: Car):
	car = _car

func _ready():
	boost_button.boost_pressed.connect(_on_boost_pressed)

func _on_boost_pressed():
	if car:
		car.effect()
		Speedboost.used()
