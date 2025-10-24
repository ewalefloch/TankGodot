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

@export_group('BonusBoost')
@export var bonus_boost_bar: ProgressBar
@export var bonus_boost_label: Label
@export var bonus_boost: Panel

@export_group('BonusBouclier')
@export var bonus_bouclier_bar: ProgressBar
@export var bonus_bouclier_label: Label
@export var bonus_bouclier: Panel
@export var bonus_bouclier_health: Label

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

func update_bonus_boost(current: float, max_value: float, active: bool) -> void:
	bonus_boost.visible = active
	if not active:
		return
	if not bonus_boost_bar:
		return
	
	# Calculer le pourcentage
	var percentage = (current / max_value) * 100.0

		
	bonus_boost_bar.value = percentage
	
	# Changer la couleur selon l'état
	var style = StyleBoxFlat.new()
	if percentage < 15.0:
		style.bg_color = Color(0.8, 0.0, 0.0)  # Rouge si presque vide
	else:
		style.bg_color = Color(0.2, 0.6, 1.0)  # Bleu normal
	
	bonus_boost_bar.add_theme_stylebox_override("fill", style)

func update_bouclier(new_health: int) -> void:
	bonus_bouclier_health.text = "Bouclier life : %d" % new_health
	bonus_bouclier_health.modulate = Color.RED
	if new_health <=0 :
		bonus_bouclier.visible = false

func updat_bonus_bouclier(current: float, max_value: float, active: bool) -> void:
	bonus_bouclier.visible = active
	if not active:
		return
	if not bonus_boost_bar:
		return
	
	# Calculer le pourcentage
	var percentage = (current / max_value) * 100.0

	bonus_bouclier_bar.value = percentage
	
	# Changer la couleur selon l'état
	var style = StyleBoxFlat.new()
	if percentage < 15.0:
		style.bg_color = Color(0.8, 0.0, 0.0)  # Rouge si presque vide
	else:
		style.bg_color = Color(0.2, 0.6, 1.0)  # Bleu normal
	
	bonus_bouclier_bar.add_theme_stylebox_override("fill", style)
