extends Node


func save_game():
	var nodes = get_tree().get_nodes_in_group("Persist")
	for node in nodes:
		if node.has_method("save"):
			node.save()
