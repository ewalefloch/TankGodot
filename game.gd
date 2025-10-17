extends Node3D

@export var tankP1: Tank
@export var tankP2: Tank
@export var victory_menu: Control
@export var main_menu: Control

# Stocker les positions initiales des tanks
var tank1_initial_position: Vector3
var tank1_initial_rotation: Vector3
var tank2_initial_position: Vector3
var tank2_initial_rotation: Vector3

func _ready() -> void:
	# Sauvegarder les positions initiales des tanks
	if tankP1:
		tank1_initial_position = tankP1.global_position
		tank1_initial_rotation = tankP1.rotation
		tankP1.died.connect(_on_tank_died)
	
	if tankP2:
		tank2_initial_position = tankP2.global_position
		tank2_initial_rotation = tankP2.rotation
		tankP2.died.connect(_on_tank_died)

func start_game() -> void:
	# Appelé quand on démarre une partie depuis le menu principal
	restart_game()
	visible = true

func restart_game() -> void:
	# Remettre le jeu en marche
	get_tree().paused = false
	
	# Cacher le menu victoire
	if victory_menu:
		victory_menu.visible = false
	
	# Réinitialiser TankP1
	if tankP1:
		tankP1.visible = true
		tankP1.global_position = tank1_initial_position
		tankP1.rotation = tank1_initial_rotation
		tankP1.health = 100
		tankP1.gold = 0
		tankP1.velocity = Vector3.ZERO
		tankP1.left_speed = 0.0
		tankP1.right_speed = 0.0
		tankP1.boost_time_remaining = tankP1.boost_max_duration
		tankP1.boost_recharge_timer = 0.0
		tankP1.is_boosting = false
		tankP1.was_fully_depleted = false
	
	# Réinitialiser TankP2
	if tankP2:
		tankP2.visible = true
		tankP2.global_position = tank2_initial_position
		tankP2.rotation = tank2_initial_rotation
		tankP2.health = 100
		tankP2.gold = 0
		tankP2.velocity = Vector3.ZERO
		tankP2.left_speed = 0.0
		tankP2.right_speed = 0.0
		tankP2.boost_time_remaining = tankP2.boost_max_duration
		tankP2.boost_recharge_timer = 0.0
		tankP2.is_boosting = false
		tankP2.was_fully_depleted = false
	
	print("Partie réinitialisée!")

func _on_tank_died(player_id: int) -> void:
	# Déterminer quel joueur a gagné
	var winner_id = 2 if player_id == 1 else 1
	var winner_name = "Joueur %d" % winner_id
	
	print("Le joueur ", player_id, " est mort. ", winner_name, " a gagné!")
	
	# Afficher le menu victoire avec le nom du gagnant
	if victory_menu:
		victory_menu.show_with_winner(winner_name)
		victory_menu.visible = true
	
	# Mettre le jeu en pause
	get_tree().paused = true
