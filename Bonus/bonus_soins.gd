# BonusSoins.gd
class_name BonusSoins
extends Bonus

@export var heal_amount: int = 25

func apply_to(tank: Node) -> void:
	if tank and tank.has_method("change_health"):
		tank.change_health(heal_amount)
