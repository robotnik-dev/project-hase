extends Control
class_name UILevelSelection

signal selected(idx: int)

@export var level_previews: Array[PackedScene]
@export var preview_viewport: Container

var current_idx: int = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		_on_navigate_left_pressed()
	elif event.is_action_pressed("ui_right"):
		_on_navigate_right_pressed()
	elif event.is_action_pressed("ui_accept"):
		selected.emit(current_idx)

func _render_preview():
	for c in preview_viewport.get_children():
		c.queue_free()
	
	var preview = level_previews[current_idx].instantiate()

	preview_viewport.add_child(preview)

func _on_navigate_left_pressed() -> void:
	if current_idx == 0:
		current_idx = level_previews.size() - 1
	else:
		current_idx -= 1
	_render_preview()


func _on_navigate_right_pressed() -> void:
	if current_idx == level_previews.size() - 1:
		current_idx = 0
	else:
		current_idx += 1
	_render_preview()
