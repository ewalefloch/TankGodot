extends Node3D

@export var tankP1: Tank
@export var tankP2: Tank
@export var victory_menu: Control
@export var main_menu: Control 

func _ready() -> void:
	# Connecter les signaux des tanks
	if tankP1:
		tankP1.died.connect(_on_tank_died)
	
	if tankP2:
		tankP2.died.connect(_on_tank_died)
	
	# S'assurer que le menu est caché au départ
	if victory_menu:
		victory_menu.visible = false

func _on_tank_died(player_id: int) -> void:
	# Déterminer quel joueur a gagné
	var winner_id = 2 if player_id == 1 else 1
	var winner_name = "Joueur %d" % winner_id
	
	print("Le joueur ", player_id, " est mort. ", winner_name, " a gagné!")
	
	# Afficher le menu victoire avec le nom du gagnant
	if victory_menu:
		victory_menu.show_with_winner(winner_name)
		victory_menu.visible=true
	
	# Optionnel : Mettre le jeu en pause (les tanks ne bougeront plus)
	get_tree().paused = true
