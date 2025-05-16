extends Control
class_name UICarSelection

signal selected(idx: int)

@export var cars: Array[PackedScene]

@export var preview_viewport: SubViewport
@export var car_label: Label

var current_idx: int = 0
var can_use: bool = false

func _ready() -> void:
	_render_preview()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		_on_navigate_left_pressed()
	elif event.is_action_pressed("ui_right"):
		_on_navigate_right_pressed()
	elif event.is_action_pressed("ui_accept"):
		if can_use:
			selected.emit(current_idx)

func _render_preview():
	for c in preview_viewport.get_children():
		c.queue_free()
	
	var car = cars[current_idx].instantiate() as Car
	if car.ui_preview:
		var collected = _load_collected()
		
		if collected >= car.collectables_needed_to_unlock:
			var preview = car.ui_preview.instantiate()
			preview_viewport.add_child(preview)
			car_label.text = car.ui_display_name
			can_use = true
		else:
			var col_str = str(collected)
			var needed_str = str(car.collectables_needed_to_unlock)
			car_label.text = col_str + "/" + needed_str
			can_use = false
	else:
		car_label.text = "No Preview set"
		can_use = false


func _load_collected() -> int:
	return Collectibles.get_sum_of_collected()


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
