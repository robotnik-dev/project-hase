extends Button
class_name UIBoostButton

signal boost_pressed

func _ready():
	hide()
	Speedboost.boost_ready.connect(_on_boost_ready)

func _on_pressed():
	boost_pressed.emit()
	hide()

func _on_boost_ready():
	show()
