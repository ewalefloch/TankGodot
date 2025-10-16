# hud.gd
class_name HUD
extends CanvasLayer

@export_group('Label')
@export
var health_label : Label
@export
var player_label : Label
@export
var player_color : Color = Color.WHITE

func _ready() -> void:
	player_label.modulate = player_color

func update_health(new_health: int) -> void:
	health_label.text = "Health: %d" % new_health
	health_label.modulate = Color.RED

func update_gold(new_gold: int) -> void:
	pass

func update_player_id(player_id: int) -> void:
	player_label.text = "Player %s" % player_id
	player_label.modulate = player_color
