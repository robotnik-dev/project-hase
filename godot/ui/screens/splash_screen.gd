extends Control
class_name UISplashScreen

signal finished

@export var anim_player: AnimationPlayer

func finished_animation():
	finished.emit()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		anim_player.play("fade_out")
	elif anim_name == "fade_out":
		finished.emit()
