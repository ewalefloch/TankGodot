# BonusBouclier.gd
class_name BonusBouclier
extends Bonus

@export var duration: float = 8.0
@export var shield_value: int = 20  # capacité du bouclier (optional)

func apply_to(tank: Node) -> void:
	if tank and tank.has_method("start_shield"):
		tank.start_shield(duration, shield_value)
