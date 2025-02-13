@tool
extends EditorPlugin


const RustLibManagerScene = preload("res://addons/rust_lib/rust_lib_manager.tscn")

var rust_lib_manager: RustLibManager


func _enter_tree():
	rust_lib_manager = RustLibManagerScene.instantiate()
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(rust_lib_manager)
	# Hide the main panel. Very much required.
	_make_visible(false)


func _exit_tree():
	if rust_lib_manager:
		rust_lib_manager.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if rust_lib_manager:
		rust_lib_manager.visible = visible


func _get_plugin_name():
	return "Rust Lib"


func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Script", "EditorIcons")
