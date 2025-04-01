extends Node
class_name CollectibleManager

## The ID for the level this Node is in. It has to be unique!
## This will be saved on the disk
@export var level_id: int = 1

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
	return SaveGame.get_collected_for_level(level_id)

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
			if c.id in collected:
				c.queue_free()
			
			id += 1

func _on_collected(id: int):
	SaveGame.collected_in_level(id, level_id)
	SaveGame.save()
