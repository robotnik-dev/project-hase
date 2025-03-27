extends Node
class_name CollectibleManager

## If activated, it wont save the collectibles to a file.
## Good for building levels without manually deleting the savefile all the time.
## 
## hint: when already saved, manually delete the file 'savegame.save' at:
## windows: %APPDATA%\Roaming\Godot\app_userdata\HASE\
@export var debug_mode: bool = false

var collected: Array = []

func _ready() -> void:
	_assign_ids()
	if !debug_mode:
		_free_aleady_collected()
	Signals.connect_collected(_on_collected)

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
		var data = json.data
		var level_name = get_parent().name
		if data["level_name"] == level_name:
			_collected = data["collected"]
		
	return _collected

func save():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var level_name = get_parent().name
	var save_data = {
		"level_name": level_name,
		"collected": collected
	}
	var data = JSON.stringify(save_data)
	save_file.store_line(data)

func _assign_ids():
	var id = 0
	while true:
		if get_child_count() <= id:
			break
		var c = get_child(id)
		c.setup(id)
		id += 1

func _free_aleady_collected():
	var id = 0
	collected = _load_collected()
	# some error occured. dont delete any nodes
	if !collected.is_empty():
		while true:
			if get_child_count() <= id:
				# end of children list
				break
			
			var c = get_child(id)
			if float(c.id) in collected:
				c.queue_free()
			
			id += 1

func _on_collected(id: int):
	collected.append(id)
