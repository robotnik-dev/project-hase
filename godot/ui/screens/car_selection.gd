extends Control
class_name UICarSelection


@export var cars: Array[PackedScene]

@export var preview_viewport: SubViewport
@export var car_label: Label

@export var start_button: Button

var current_idx: int = 0

func _ready() -> void:
	_render_preview()
	start_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		_on_navigate_left_pressed()
	elif event.is_action_pressed("ui_right"):
		_on_navigate_right_pressed()

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
			start_button.disabled = false
		else:
			var col_str = str(collected)
			var needed_str = str(car.collectables_needed_to_unlock)
			car_label.text = col_str + "/" + needed_str
			start_button.disabled = true
	else:
		car_label.text = "No Preview set"


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
