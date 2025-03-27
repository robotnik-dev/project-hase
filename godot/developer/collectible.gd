extends Node3D
class_name Collectible

@export var despawn_delay: float = 0.1

var id: int = -1

func setup(_id: int):
	id = _id

func _despawn():
	queue_free()

func _on_area_3d_body_entered(_body: Node3D) -> void:
	Signals.emit_collected(id)
	# TODO: sound or particle effect
	create_tween().tween_callback(_despawn).set_delay(despawn_delay)
