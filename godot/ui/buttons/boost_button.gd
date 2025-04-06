extends Button
class_name UIBoostButton

signal boost_pressed

var spacebar_icon: CompressedTexture2D = preload("res://assets/ui/icons/spacebar_filled_icon.png")
var a_button_icon: CompressedTexture2D = preload("res://assets/ui/icons/xbox_X.png")

func _ready():
	hide()
	Speedboost.boost_ready.connect(_on_boost_ready)

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		icon = a_button_icon
	else:
		icon = spacebar_icon

func _on_pressed():
	boost_pressed.emit()
	hide()

func _on_boost_ready():
	show()
