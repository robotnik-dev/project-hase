@tool
extends Control
class_name RustLibManager

@export var install_button: Button
@export var build_button: Button
@export var output: Label

func rust_is_installed(value: bool):
	install_button.visible = !value

func needs_to_rebuild(value: bool):
	build_button.visible = value

func project_built(value: bool):
	build_button.visible = !value

func set_output_message_array(msg: PackedStringArray):
	var str = "\n".join(msg)
	output.text = str

func append_output_message(msg: String):
	output.text = output.text + "\n" + msg

func set_output_message(msg: String):
	output.text = msg

func cargo_diff() -> Array:
	var output = []
	var exit_code = OS.execute("CMD.exe", ["/C", "addons\\rust_lib\\helper\\cargo_diff.bat"], output, true)
	var pretty: PackedStringArray = []
	for out in output:
		out = out as String
		out.replace("\r", "")
		pretty.append_array(out.split("\n"))
	
	return [exit_code, pretty]

func check_rust_installation() -> Array:
	var output = []
	var exit_code = OS.execute("CMD.exe", ["/C", "addons\\rust_lib\\helper\\check_rust.bat"], output, true)
	var pretty: PackedStringArray = []
	for out in output:
		out = out as String
		out.replace("\r", "")
		pretty.append_array(out.split("\n"))
	
	return [exit_code, pretty]

func install_rust() -> Array:
	var output = []
	var exit_code = OS.execute("CMD.exe", ["/C", "addons\\rust_lib\\helper\\install_rust.bat"], output, true)
	var pretty: PackedStringArray = []
	for out in output:
		out = out as String
		out.replace("\r", "")
		pretty.append_array(out.split("\n"))
	
	return [exit_code, pretty]

func build_rust() -> Array:
	var output = []
	var exit_code = OS.execute("CMD.exe", ["/C", "addons\\rust_lib\\helper\\build_rust.bat"], output, true)
	var pretty: PackedStringArray = []
	for out in output:
		out = out as String
		out.replace("\r", "")
		pretty.append_array(out.split("\n"))
	
	return [exit_code, pretty]


func _on_install_pressed() -> void:
	set_output_message("Installing rust, please wait...")
	await get_tree().create_timer(0.5).timeout
	var error = install_rust()
	if error[0] == 1:
		set_output_message_array(error[1])
	else:
		rust_is_installed(true)
		set_output_message("Rust was installed. \n Please reload the project!")


func _on_build_pressed() -> void:
	set_output_message("Building the project, please wait...")
	await get_tree().create_timer(0.5).timeout
	var error = build_rust()
	set_output_message_array(error[1])
	if error[0] == 1:
		needs_to_rebuild(true)
	else:
		project_built(true)
		append_output_message("Everything up to date")
		set_output_message("Everything up to date. \n Please reload the project!")

func _on_visibility_changed() -> void:
	install_button.visible = false
	build_button.visible = false
	if visible:
		set_output_message("Checking rust installation, please wait...")
		await get_tree().create_timer(1.0).timeout
		var install_error = check_rust_installation()
		if install_error[0] == 1:
			set_output_message_array(install_error[1])
		else:
			rust_is_installed(true)
			set_output_message("Rust ist installed. \n Checking for new code changes, please wait...")
			await get_tree().create_timer(1.0).timeout
			var cargo_error = cargo_diff()
			set_output_message_array(cargo_error[1])
			if cargo_error[0] == 1:
				needs_to_rebuild(true)
				append_output_message("Please rebuild")
			else:
				append_output_message("Everything up to date")
				needs_to_rebuild(false)
