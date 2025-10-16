# hud.gd
class_name HUD
extends CanvasLayer

@export_group('Label')
@export
var health_label : Label
@export
var gold_label : Label

func update_health(new_health: int) -> void:
	health_label.text = "Health: %d" % new_health
	health_label.modulate = Color.RED

func update_gold(new_gold: int) -> void:
	gold_label.text = "Gold: %d" % new_gold
	gold_label.modulate = Color.YELLOW
