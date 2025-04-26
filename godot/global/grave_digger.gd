extends Node

var graves: Array = []
var grave_scene: PackedScene = preload("res://graves/grave.tscn")
var raycast: RayCast3D = RayCast3D.new()

func _ready():
	Signals.connect_car_crashed(_on_car_crashed)
	Signals.connect_new_level_started(_on_new_level)
	_setup_ray()

func _setup_ray():
	raycast.target_position.y = -10
	add_child(raycast)

func _reset_ray():
	raycast.force_raycast_update()

func _get_funny_text() -> String:
	return ContentLoader.get_grave_texts().pick_random()

func _get_random_number(low: float, high: float) -> float:
	return randf_range(low, high)

func _on_car_crashed(position: Vector3, last_poc: Vector3, _abyss: bool):
	# set ray to the car position
	raycast.global_position = position
	raycast.force_raycast_update()
	create_tween().tween_callback(_place_grave.bind(position, last_poc)).set_delay(0.1)

func _place_grave(position: Vector3, last_poc: Vector3):
	var grave = grave_scene.instantiate() as Grave
	add_child(grave)
	position.x += _get_random_number(5., 10.)
	var result = _find_intersection_and_angle()
	if result.x == 0:
		# no intersection means we fell down a cliff.
		# use the last point of contact for the position
		position.y = last_poc.y
		position.z = last_poc.z
	else:
		position.y = result.x
	
	#TODO: randomize the z pos (left , right) a bit
	
	var angle = result.y
	grave.setup(position, angle, _get_funny_text())
	graves.append(grave)

func _find_intersection_and_angle() -> Vector2:
	var intersection = 0
	var angle = 0
	
	if raycast.is_colliding():
		intersection = raycast.get_collision_point().y
		angle = raycast.get_collision_normal().signed_angle_to(Vector3.UP, Vector3.LEFT)
	
	return Vector2(intersection, angle)

func _on_new_level(_id: int):
	for g in graves:
		g.queue_free()
	graves.clear()
