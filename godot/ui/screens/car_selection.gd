extends Control
class_name UICarSelection


@export var cars: Array[PackedScene]

@export var preview_viewport: SubViewport
@export var car_label: Label

@export var navigate_left: TextureButton
@export var navigate_right: TextureButton

var current_idx: int = 0

func _ready() -> void:
	navigate_right.grab_focus()
	_render_preview()

func _render_preview():
	for c in preview_viewport.get_children():
		c.queue_free()
	
	var car = cars[current_idx].instantiate()
	if car.ui_preview:
		var preview = car.ui_preview.instantiate()
		preview_viewport.add_child(preview)
		car_label.text = car.ui_display_name
	else:
		car_label.text = "No Preview set"


func _on_navigate_left_pressed() -> void:
	if current_idx == 0:
		current_idx = cars.size() - 1
	else:
		current_idx -= 1
	_render_preview()


func _on_navigate_right_pressed() -> void:
	if current_idx == cars.size() - 1:
		current_idx = 0
	else:
		current_idx += 1
	_render_preview()
