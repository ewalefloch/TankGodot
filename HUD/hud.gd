# hud.gd
class_name HUD
extends CanvasLayer

@export_group('Label')
@export var health_label: Label
@export var player_label: Label
@export var player_color: Color = Color.WHITE

@export_group('Boost')
@export var boost_bar: ProgressBar
@export var boost_label: Label

func _ready() -> void:
	player_label.modulate = player_color
	
	# Configuration de la barre de boost
	if boost_bar:
		boost_bar.min_value = 0.0
		boost_bar.max_value = 100.0
		boost_bar.value = 100.0
		
		# Style de la barre (couleurs)
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.6, 1.0)  # Bleu pour le boost
		boost_bar.add_theme_stylebox_override("fill", style)

func update_health(new_health: int) -> void:
	health_label.text = "Health: %d" % new_health
	health_label.modulate = Color.RED

func update_gold(new_gold: int) -> void:
	pass

func update_player_id(player_id: int) -> void:
	player_label.text = "Player %s" % player_id
	player_label.modulate = player_color

# NOUVEAU : Mettre à jour le boost
func update_boost(current: float, max_value: float, is_recharging: bool) -> void:
	if not boost_bar:
		return
	
	# Calculer le pourcentage
	var percentage = (current / max_value) * 100.0
	boost_bar.value = percentage
	
	# Changer la couleur selon l'état
	var style = StyleBoxFlat.new()
	if is_recharging:
		style.bg_color = Color(0.8, 0.4, 0.0)  # Orange pendant recharge
	elif percentage < 35.0:
		style.bg_color = Color(0.8, 0.0, 0.0)  # Rouge si presque vide
	else:
		style.bg_color = Color(0.2, 0.6, 1.0)  # Bleu normal
	
	boost_bar.add_theme_stylebox_override("fill", style)
