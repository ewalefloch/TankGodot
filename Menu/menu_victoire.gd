extends Control

@export var game_node: Node3D  # Le nœud contenant le jeu
@export var main_menu: Control  # Référence au menu principal
@export var winner_label: Label
@export var restart_btn: Button
@export var title_btn: Button

func _ready() -> void:
	visible = false
	
	if restart_btn:
		restart_btn.pressed.connect(_on_restart_pressed)
	if title_btn:
		title_btn.pressed.connect(_on_main_menu_pressed)
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_with_winner(winner_name: String) -> void:
	if winner_label:
		winner_label.text = "VICTOIRE DE %s !" % winner_name
	
	visible = true
	
	if restart_btn:
		restart_btn.grab_focus()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	visible = false
	
	# Réinitialiser et redémarrer le jeu
	if game_node:
		if game_node.has_method("restart_game"):
			game_node.restart_game()
		else:
			# Fallback : recharger la scène complète
			get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	visible = false
	
	# Retourner au menu principal
	if main_menu:
		main_menu.show_main_menu()
