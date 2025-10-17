extends Control

@export var game_node: Node3D  # Le nœud contenant le jeu (tanks, map, etc.)
@export var victory_menu: Control  # Référence au menu victoire
@export var start_btn: Button
@export var quit_btn: Button

func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	start_btn.grab_focus()
	
	# Au démarrage, cacher le jeu et le menu victoire
	if game_node:
		game_node.visible = false
	if victory_menu:
		victory_menu.visible = false

func _on_start_pressed() -> void:
	# Cacher ce menu
	visible = false
	
	# Afficher et démarrer le jeu
	if game_node:
		game_node.visible = true
		# Réinitialiser le jeu si nécessaire
		if game_node.has_method("start_game"):
			game_node.start_game()
	
	get_tree().paused = false

func _on_quit_pressed() -> void:
	get_tree().quit()

# Fonction pour revenir au menu principal depuis le jeu
func show_main_menu() -> void:
	visible = true
	start_btn.grab_focus()
	if game_node:
		game_node.visible = false
	if victory_menu:
		victory_menu.visible = false
	get_tree().paused = false
