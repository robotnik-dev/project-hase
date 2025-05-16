extends Node

var crashes: int = 0
var flips: int = 0
var playtime: float = 0.0:
	get():
		return roundf(Time.get_ticks_msec() / 1000.0 / 60.0)

var cars_unlocked: int = 1:
	get():
		var sum_collected = Collectibles.get_sum_of_collected()
		if sum_collected >= 12:
			return 3
		elif sum_collected <= 0:
			return 1
		elif sum_collected >= 6:
			return 2
		else:
			return 0

var max_cars: int = 3
var collected: int = 0:
	get():
		return Collectibles.get_sum_of_collected()
var max_collectibles: int = 19
var level_completed: int = 0

func _ready() -> void:
	Signals.connect_car_crashed(func(_a,_b,_c): crashes += 1)
	Signals.connect_car_flipped(func(_a,_b): flips += 1)
	# TODO: maybe differentiate between levels here but ones the first level completes,
	# unlock all for now
	Signals.connect_car_finished(func(): level_completed += 1)
