extends Node

var crashes: int = 0
var playtime: float = 0.0:
	get():
		return roundf(Time.get_ticks_msec() / 1000.0 / 60.0)

var cars_unlocked: int = 0:
	get():
		if collected <= 0:
			return 1
		elif collected >= 6:
			return 2
		elif collected >= 9:
			return 3
		else:
			return 0

var max_cars: int = 3
var collected: int = 0:
	get():
		return SaveGame.get_sum_of_collected()
var max_collectibles: int = 9

func _ready() -> void:
	Signals.connect_car_crashed(func(_a,_b,_c): crashes += 1)
