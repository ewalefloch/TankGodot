class_name Projectile
extends Node3D
# Projectile simple sans collision - Godot 4.5
# Indentation : TAB

@export var speed: float = 1.0       # m/s
@export var lifetime: float = 2.0     # secondes avant destruction automatique
@export var mesh_scale: float = 0.2   # taille du mesh visuel si tu veux scale

var direction: Vector3 = Vector3.ZERO
var shooter: Node = null  # paramètre pour compatibilité, non utilisé ici

func setup(dir: Vector3, shooter_node: Node = null) -> void:
	direction = dir.normalized()
	shooter = shooter_node

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta: float) -> void:
	if direction == Vector3.ZERO:
		return
	translate(direction * speed * delta)
