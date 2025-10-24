# BonusBoostTemp.gd
class_name BonusBoostTemp
extends Bonus

@export var duration: float = 10.0
@export var boost_multiplier: float = 2.0  # factor pour boost

func apply_to(tank: Node) -> void:
	if tank and tank.has_method("start_boost_powerup"):
		tank.start_boost_powerup(duration)
