@tool
extends Control
class_name RustLibManager

@export var label_container: VBoxContainer

var label_scene = preload("res://addons/rust_lib/scenes/output_label.tscn")

class Process:
	signal finished(error)
	
	var stdio: FileAccess
	var stderr: FileAccess
	var pid: int
	
	func _init(process_dict: Dictionary) -> void:
		self.stdio = process_dict["stdio"]
		self.stderr = process_dict["stderr"]
		self.pid = process_dict["pid"]
	
	func tick():
		if !_is_process_running():
			finished.emit(OS.get_process_exit_code(pid))
	
	func _is_process_running() -> bool:
		return OS.is_process_running(pid)
	
	func kill() -> int:
		return OS.kill(pid)
	
	func next_line() -> String:
		var next = stdio.get_line()
		return next if next != "" else stderr.get_line()

var processes: Array[Process] = []

func _process(delta: float) -> void:
	for process in processes:
		append_output_message(process.next_line())
		process.tick()


func append_output_message(msg: String, color: Color = Color.AZURE):
	if msg == "":
		return
	
	var time = Time.get_time_string_from_system()
	var formated_msg = time + ": " + msg
	var label: Label = label_scene.instantiate()
	label.text = formated_msg
	label.label_settings.font_color = color
	
	label_container.add_child(label)

func clear_output_message():
	for c in label_container.get_children():
		c.queue_free()

func execute(cmd: String, extra_args: Array = []) -> Process:
	var args = ["/C", "addons\\rust_lib\\helper\\" + cmd + ".bat"]
	args.append_array(extra_args)
	return Process.new(OS.execute_with_pipe("CMD.exe", args))

func cargo_diff() -> Process:
	return execute("cargo_diff")

func check_rust() -> Process:
	return execute("check_rust")

func install_rust() -> Process:
	return execute("install_rust")

func build_rust() -> Process:
	return execute("build_rust")

func _on_check_rust_finished(error: int, process: Process):
	processes.erase(process)
	if error != OK:
		append_output_message("Rust will be installed. Please wait ...", Color.DEEP_PINK)
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
		append_output_message("Rebuilding the project. Please wait ...", Color.DEEP_PINK)
		var p_build_rust = build_rust()
		processes.append(p_build_rust)
		p_build_rust.finished.connect(_on_build_rust_finished.bind(p_build_rust))
	else:
		append_output_message("Code is up to date!", Color.CHARTREUSE)

func _on_build_rust_finished(error: int, process: Process):
	processes.erase(process)
	if error == OK:
		append_output_message(
			"Please RELOAD the Editor (and any other terminal or VSCode) for changes to take effect. \n
			If this message keeps reappearing, restart your computer",
			Color.ORANGE_RED
		)
	else:
		append_output_message(
			"Some error happend while building. Please try again",
			Color.ORANGE_RED
		)

func _on_install_rust_finished(error: int, process: Process):
	processes.erase(process)
	if error == OK:
		append_output_message(
			"Please RELOAD the Editor (and any other terminal or VSCode) for changes to take effect. \n
			If this message keeps reappearing, restart your computer",
			Color.ORANGE_RED
		)
	else:
		append_output_message(
			"Some error happend while building. Please try again",
			Color.ORANGE_RED
		)

func _on_reload_pressed() -> void:
	clear_output_message()
	if OS.get_name() != "Windows":
		append_output_message(
			"This works only on Windows machines. \n
			Install Rust and build the project manually",
			Color.ORANGE_RED
		)
		return
	var p_check_rust = check_rust()
	processes.append(p_check_rust)
	p_check_rust.finished.connect(_on_check_rust_finished.bind(p_check_rust))
