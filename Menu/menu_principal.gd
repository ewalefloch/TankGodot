extends Control

@export var level_scene: PackedScene = null
@export var start_btn: Button
@export var quit_btn: Button

func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	start_btn.grab_focus()
	get_tree().paused = false

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(level_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()
