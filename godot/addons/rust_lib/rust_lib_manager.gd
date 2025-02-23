@tool
extends Control
class_name RustLibManager

@export var output: Label

class Process:
	signal finished(error)
	
	var stdio: FileAccess
	var stderr: FileAccess
	var pid: int
	
	func tick():
		if !_is_process_running():
			finished.emit(OS.get_process_exit_code(pid))
	
	func _is_process_running() -> bool:
		return OS.is_process_running(pid)
	
	func kill() -> int:
		return OS.kill(pid)
	
	func next_line() -> String:
		return stdio.get_line()

var processes: Array[Process] = []
var rust_installed: bool = false
var need_rebuild: bool = false

func _process(delta: float) -> void:
	for process in processes:
		append_output_message(process.next_line())
		process.tick()

func set_output_message_array(msg: PackedStringArray):
	var str = "\n".join(msg)
	output.text = str

func append_output_message(msg: String):
	if msg == "":
		return
	
	var time = Time.get_time_string_from_system()
	var formated_msg = time + ": " + msg
	output.text = output.text + "\n" + formated_msg + "\n"

func set_output_message(msg: String):
	output.text = msg

func clear_output_message():
	output.text = ""

func execute(os: String, cmd: String) -> Process:
	var process = Process.new()
	var process_dict: Dictionary = {}
	match os:
		"Windows":
			process_dict = OS.execute_with_pipe("CMD.exe", ["/C", "addons\\rust_lib\\helper\\" + cmd + ".bat"])
		"MacOS":
			# TODO
			pass
		"Linux":
			# TODO
			pass
	
	process.stdio = process_dict["stdio"]
	process.stderr = process_dict["stderr"]
	process.pid = process_dict["pid"]
	
	return process

func cargo_diff() -> Process:
	return execute(OS.get_name(), "cargo_diff")

func check_rust() -> Process:
	return execute(OS.get_name(), "check_rust")

func install_rust() -> Process:
	return execute(OS.get_name(), "install_rust")

func build_rust() -> Process:
	return execute(OS.get_name(), "build_rust")

func _on_check_rust_finished(error: int, process: Process):
	processes.erase(process)
	if error != OK:
		append_output_message("Rust will be installed. Please wait ...")
		var p_install_rust = install_rust()
		processes.append(p_install_rust)
		p_install_rust.finished.connect(_on_install_rust_finished.bind(p_install_rust))
	
	else:
		# check latest changes
		var p_cargo_diff = cargo_diff()
		processes.append(p_cargo_diff)
		p_cargo_diff.finished.connect(_on_cargo_diff_finished.bind(p_cargo_diff))

func _on_cargo_diff_finished(error: int, process: Process):
	processes.erase(process)
	if error == OK:
		append_output_message("Rebuilding the project. Please wait ...")
		var p_build_rust = build_rust()
		processes.append(p_build_rust)
		p_build_rust.finished.connect(_on_build_rust_finished.bind(p_build_rust))
	else:
		append_output_message("Code is up to date!")

func _on_build_rust_finished(error: int, process: Process):
	processes.erase(process)
	if error == OK:
		append_output_message("Code is up to date!")
		append_output_message("Please RELOAD! the project for changes to take effect.")
	else:
		append_output_message("Some error happend while building. Please try again")

func _on_install_rust_finished(error: int, process: Process):
	processes.erase(process)
	if error == OK:
		append_output_message("Please RELOAD! the project for changes to take effect.")
	else:
		append_output_message("Some error happend while installing. Please try again")

func _on_reload_pressed() -> void:
	clear_output_message()
	var p_check_rust = check_rust()
	processes.append(p_check_rust)
	p_check_rust.finished.connect(_on_check_rust_finished.bind(p_check_rust))
