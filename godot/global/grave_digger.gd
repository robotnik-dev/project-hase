extends Node

var graves: Array = []
var grave_scene: PackedScene = preload("res://graves/grave.tscn")
var raycast: RayCast3D = RayCast3D.new()

var max_graves: int = 100

func _ready():
	Signals.connect_car_crashed(_on_car_crashed)
	Signals.connect_new_level_started(_on_new_level)
	_setup_ray()
	_setup_graves_pool()

func _setup_graves_pool():
	for i in max_graves:
		var grave = grave_scene.instantiate() as Grave
		add_child(grave)
		var pos = Vector3(-100,0,0)
		grave.setup(pos, 0, "")
		graves.append(grave)

func _setup_ray():
	raycast.target_position.y = -10
	add_child(raycast)

func _reset_ray():
	raycast.force_raycast_update()

func _get_funny_text() -> String:
	return ContentLoader.get_grave_texts().pick_random()

func _get_random_number(low: float, high: float) -> float:
	return randf_range(low, high)

func _on_car_crashed(position: Vector3, last_poc: Vector3, abyss: bool):
	# set ray to the car position
	raycast.global_position = position
	raycast.force_raycast_update()
	create_tween().tween_callback(_place_grave.bind(position, last_poc, abyss)).set_delay(0.1)

func _place_grave(position: Vector3, last_poc: Vector3, abyss: bool):
	var grave = graves.filter(func(g): return !g.used)[0] as Grave
	if !grave:
		# all graves in the pool are used.
		# Set all to unused and start fresh (essentilaly deleting the first places grave)
		graves = graves.map(_reset_grave)
		grave = graves.filter(func(g): return !g.used)
	
	position.x += _get_random_number(5., 10.)
	var angle = 0
	if abyss:
		# use the last point of contact for the position
		position.y = last_poc.y
		position.z = last_poc.z
	else:
		var result = _find_intersection_and_angle()
		position.y = result.x
		angle = result.y
	
	# when the grave intersects with another, then spawn the new one on top of it
	var intersect_graves = graves.map(_intersects.bind(position)).filter(func(g): return g != null)
	for g in intersect_graves:
		position.y += g.height
		angle = g.get_angle()
	
	grave.setup(position, angle, _get_funny_text())
	grave.used = true

func _find_intersection_and_angle() -> Vector2:
	var intersection = 0
	var angle = 0
	
	if raycast.is_colliding():
		intersection = raycast.get_collision_point().y
		angle = raycast.get_collision_normal().signed_angle_to(Vector3.UP, Vector3.LEFT)
	
	return Vector2(intersection, angle)

func _on_new_level(_id: int):
	graves = graves.map(_reset_grave)

func _reset_grave(grave: Grave) -> Grave:
	grave.used = false
	return grave

# reurns grave or null. 'other' is the one who will be compared against all other
func _intersects(grave: Grave, other: Vector3) -> Grave:
	if absf(other.z - grave.global_position.z) <= (grave.width / 2):
		return grave
	else:
		return null
