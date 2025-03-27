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
	# TODO: check the sum of all collected in every level with the car.collectables_needed_to_unlock
	for c in preview_viewport.get_children():
		c.queue_free()
	
	var car = cars[current_idx].instantiate()
	if car.ui_preview:
		var preview = car.ui_preview.instantiate()
		preview_viewport.add_child(preview)
		car_label.text = car.ui_display_name
	else:
		car_label.text = "No Preview set"

func _load_collected() -> Array:
	var _collected: Array = []
	if not FileAccess.file_exists("user://savegame.save"):
		return [] # Error! We don't have a save to load.
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		
		# Creates the helper class to interact with JSON.
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		# Get the data from the JSON object.
		# TODO: for every level
		var data = json.data
		var level_name = get_parent().name
		if data["level_name"] == level_name:
			_collected = data["collected"]
		
	return _collected


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
