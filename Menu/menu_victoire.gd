extends Control

@export var level_scene: PackedScene = null
@export var main_menu_scene: PackedScene = null
@export var winner_label: Label
@export var restart_btn: Button
@export var title_btn: Button

func _ready() -> void:
	visible = false
	restart_btn.pressed.connect(_on_restart_pressed)
	title_btn.pressed.connect(_on_main_menu_pressed)
	
	# Important : Ne pas mettre en pause ce Control quand le jeu est en pause
	process_mode = Node.PROCESS_MODE_ALWAYS

# Appelé par le Level quand une partie est finie
func show_with_winner(winner_name: String) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("show_with_winner")
	winner_label.text = "Player %s gagne !" % winner_name
	visible = true
	# Donner le focus pour que ui_accept déclenche le bouton
	restart_btn.grab_focus()

func _on_restart_pressed() -> void:
	# Remettre le jeu en marche
	get_tree().paused = false
	
	if level_scene != null:
		get_tree().change_scene_to_packed(level_scene)
	else:
		# Fallback : recharger la scène actuelle
		get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	# Remettre le jeu en marche
	get_tree().paused = false
	
	if main_menu_scene != null:
		get_tree().change_scene_to_packed(main_menu_scene)
	else:
		# Fallback : aller au menu principal par chemin
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
