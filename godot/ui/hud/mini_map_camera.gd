extends Camera3D

func _physics_process(_delta: float) -> void:
	var camera = get_tree().get_first_node_in_group("PlayerCamera")
	if camera:
		global_position.z = camera.global_position.z
		global_position.y = camera.global_position.y + camera.height
