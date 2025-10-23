class_name Turret
extends Node3D

@export_group("Contrôles")
@export var player_id: int = 1

@export_group("Rotation")
@export var yaw_speed_deg: float = 90.0
@export var yaw_smoothing: float = 8.0
@export var yaw_limit_left_deg: float = -180.0
@export var yaw_limit_right_deg: float = 180.0

@onready var turret_base: Node3D = $turret_base if has_node("turret_base") else self
@onready var barrel: Node3D = $barrel if has_node("barrel") else null

#Shoot
@export_group("Armes")
@export var projectile_scene: PackedScene = null
@export var projectile_speed: float = 80.0
@export var projectile_lifetime: float = 5.0
@export var projectile_damage: int = 1
@export var fire_cooldown: float = 1.0
@export var muzzle_path: NodePath
@export var song_shot: AudioStreamPlayer3D

# Nouveau : Paramètres de recul
@export_group("Recul")
@export var recoil_force: float = 3.0  # Force du recul en m/s
@export var recoil_duration: float = 0.2  # Durée du recul en secondes

@onready var muzzle: Node3D = get_node_or_null(muzzle_path)

var time_since_last_shot: float = 0.0

# Internal state (radians)
var yaw_target: float = 0.0
var yaw_current: float = 0.0
var pitch_target: float = 0.0
var pitch_current: float = 0.0

func _ready() -> void:
	yaw_current = turret_base.rotation.y
	yaw_target = yaw_current

func _physics_process(delta: float) -> void:
	var input_yaw_left: String = "p%s_turret_left" % player_id
	var input_yaw_right: String = "p%s_turret_right" % player_id
	var input_fire: String = "p%s_fire" % player_id
	
	var yaw_input: float = 0.0
	if Input.is_action_pressed(input_yaw_left):
		yaw_input += 1.0
	if Input.is_action_pressed(input_yaw_right):
		yaw_input -= 1.0
		
	time_since_last_shot = max(0.0, time_since_last_shot - delta)
	
	if Input.is_action_pressed(input_fire) and time_since_last_shot <= 0.0:
		shoot()

	var yaw_speed = deg_to_rad(yaw_speed_deg) * yaw_input
	yaw_target += yaw_speed * delta

	var yaw_min = deg_to_rad(yaw_limit_left_deg)
	var yaw_max = deg_to_rad(yaw_limit_right_deg)
	yaw_target = clamp(yaw_target, yaw_min, yaw_max)

	var t_yaw = clamp(yaw_smoothing * delta, 0.0, 1.0)
	yaw_current = lerp_angle(yaw_current, yaw_target, t_yaw)

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
	
	# Vérification du son
	if song_shot == null:
		push_warning("song_shot AudioStreamPlayer3D not found")
	elif song_shot.stream == null:
		push_warning("No audio stream assigned to song_shot")
	
	# Créer le projectile
	var proj = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_transform = muzzle.global_transform
	var dir: Vector3 = muzzle.global_transform.basis.z.normalized()
	
	if proj.has_method("setup"):
		proj.setup(dir, null)
	if "speed" in proj:
		proj.speed = projectile_speed
	if "lifetime" in proj:
		proj.lifetime = projectile_lifetime
	
	# Appliquer le recul au tank
	apply_recoil_to_tank(-dir)
	# Jouer le son
	if song_shot and song_shot.stream:
		# Créer un joueur temporaire global
		var global_player = AudioStreamPlayer.new()
		global_player.stream = song_shot.stream
		global_player.volume_db = 0
		get_tree().root.add_child(global_player)
		global_player.play()

		# Supprimer après lecture
		global_player.finished.connect(func(): global_player.queue_free())

	time_since_last_shot = fire_cooldown

func apply_recoil_to_tank(shoot_direction: Vector3) -> void:
	# Trouver le tank parent
	var tank = get_parent()
	if tank and tank is Tank:
		# Direction opposée au tir
		var recoil_direction = -shoot_direction
		# Appliquer le recul
		tank.apply_recoil(recoil_direction, recoil_force, recoil_duration)
