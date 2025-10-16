class_name Turret
extends Node3D

@export_group("Contrôles")
@export var player_id: int = 1

@export_group("Rotation")
@export var yaw_speed_deg: float = 90.0      # deg/s quand on appuie RB/LB
@export var yaw_smoothing: float = 8.0       # plus grand = plus lisse
@export var yaw_limit_left_deg: float = -180.0   # optionnel : limite de rotation relative
@export var yaw_limit_right_deg: float = 180.0

# Nodes references (set in inspector or found on _ready)
@onready var turret_base: Node3D = $turret_base if has_node("turret_base") else self
@onready var barrel: Node3D = $barrel if has_node("barrel") else null


#Shoot
@export_group("Armes")
@export var projectile_scene: PackedScene = null
@export var projectile_speed: float = 80.0
@export var projectile_lifetime: float = 5.0
@export var projectile_damage: int = 1
@export var fire_cooldown: float = 1.0
# expose a NodePath to assign the muzzle in the inspector
@export var muzzle_path: NodePath

@onready var muzzle: Node3D = get_node_or_null(muzzle_path)

var time_since_last_shot: float = 0.0

# Internal state (radians)
var yaw_target: float = 0.0
var yaw_current: float = 0.0
var pitch_target: float = 0.0
var pitch_current: float = 0.0

func _ready() -> void:
	# initialise états à la rotation actuelle
	yaw_current = turret_base.rotation.y
	yaw_target = yaw_current

func _physics_process(delta: float) -> void:
	var input_yaw_left: String = "p%s_turret_left" % player_id
	var input_yaw_right: String = "p%s_turret_right" % player_id
	var input_fire: String = "p%s_fire" % player_id
	# --- 1) Lire inputs numériques (RB/LB ou clavier), valeur -1,0,1
	var yaw_input: float = 0.0
	if Input.is_action_pressed(input_yaw_left):
		yaw_input += 1.0
	if Input.is_action_pressed(input_yaw_right):
		yaw_input -= 1.0
		
	time_since_last_shot = max(0.0, time_since_last_shot - delta)
	
	if Input.is_action_pressed(input_fire) and time_since_last_shot <= 0.0:
		shoot()

	# --- 2) Calculer la vitesse cible en radians/s
	var yaw_speed = deg_to_rad(yaw_speed_deg) * yaw_input

	# Mettre à jour la cible de yaw (intégration simple)
	yaw_target += yaw_speed * delta

	# Option : limiter la rotation relative (si tu veux empêcher full 360)
	# Convertir la rotation de référence (ici on considère yaw 0 comme initial)
	var yaw_min = deg_to_rad(yaw_limit_left_deg)
	var yaw_max = deg_to_rad(yaw_limit_right_deg)
	yaw_target = clamp(yaw_target, yaw_min, yaw_max)

	# Lissage / interpolation du yaw courant vers la cible
	var t_yaw = clamp(yaw_smoothing * delta, 0.0, 1.0)
	yaw_current = lerp_angle(yaw_current, yaw_target, t_yaw)

	# Appliquer rotation sur turret_base (rotation.y = yaw)
	var rot = turret_base.rotation
	rot.y = yaw_current
	turret_base.rotation = rot

func shoot() -> void:
	if projectile_scene == null:
		push_warning("No projectile_scene set")
		return
	if muzzle == null:
		push_warning("No muzzle_point")
		return
	var proj = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_transform = muzzle.global_transform
	var dir: Vector3 = muzzle.global_transform.basis.z.normalized()
	if proj.has_method("setup"):
		proj.setup(dir, null)  # on passe null pour shooter car pas utilisé ici
	# config optionnelle si exposée
	if "speed" in proj:
		proj.speed = projectile_speed
	if "lifetime" in proj:
		proj.lifetime = projectile_lifetime
	time_since_last_shot = fire_cooldown
