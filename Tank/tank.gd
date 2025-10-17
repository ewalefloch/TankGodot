class_name Tank
extends CharacterBody3D

@export_group("Contrôles")
@export var player_id: int = 1
@export var turret: Turret

# --- Réglages (exposés dans l'inspecteur)
@export_group('Vitesse')
@export var max_forward_speed: float = 4.0
@export var max_reverse_speed: float = 3.5
@export var track_width: float = 2.0
@export var use_smoothing: bool = true
@export var accel: float = 10.0
@export var linear_damping: float = 4.0

# --- Quantize options
@export var use_quantize: bool = true
@export var quantize_threshold: float = 0.5   # >threshold => 1, between => 0, < -threshold => -1

# --- Boost
@export_group("Boost")
@export var boost_multiplier: float = 2  # 100% plus vite
@export var boost_max_duration: float = 5.0  # durée max du boost
@export var boost_recharge_delay: float = 20.0  # temps avant recharge si épuisé
@export var boost_partial_recharge_rate: float = 0.333  # 1 sec tous les 3s (1/3)
@export var boost_input: String = "boost"  # nom de l'action input

# --- Debug
@export var debug_print: bool = false

@export_group("Info")
@export var health: int = 100:
	set(value):
		health = value
		# Émet le signal avec la nouvelle valeur
		health_changed.emit(health)
@export var gold: int = 0:
	set(value):
		gold = value
		gold_changed.emit(gold)

# --- signal pour le HUD
signal health_changed(new_health: int)
signal gold_changed(new_gold: int)
signal died(player_id: int)

# --- Etats internes (vitesses des chenilles en m/s)
var left_speed: float = 0.0
var right_speed: float = 0.0

# Variables internes du boost
var boost_time_remaining: float = 5.0  # temps de boost disponible
var boost_recharge_timer: float = 0.0  # timer pour la recharge complète
var is_boosting: bool = false
var was_fully_depleted: bool = false

func _physics_process(delta: float) -> void:
	# 1. Gérer la logique du boost (cette fonction externe ne change pas)
	handle_boost(delta)
	turret.player_id = player_id
	var left_forward_action = "p%s_left_forward" % player_id
	var left_backward_action = "p%s_left_backward" % player_id
	var right_forward_action = "p%s_right_forward" % player_id
	var right_backward_action = "p%s_right_backward" % player_id
	
	
	# 2. Déterminer le multiplicateur de vitesse en fonction du boost
	var speed_multiplier = boost_multiplier if is_boosting else 1.0
	
	var left_input: float = 0.0
	var right_input: float = 0.0
	
	left_input = Input.get_action_strength(left_forward_action) - Input.get_action_strength(left_backward_action)
	right_input = Input.get_action_strength(right_forward_action) - Input.get_action_strength(right_backward_action)
	if use_quantize:
		if left_input > quantize_threshold:
			left_input = 1.0
		elif left_input < -quantize_threshold:
			left_input = -1.0
		else:
			left_input = 0.0

		if right_input > quantize_threshold:
			right_input = 1.0
		elif right_input < -quantize_threshold:
			right_input = -1.0
		else:
			right_input = 0.0

	# --- 3) Mapping input -> vitesse cible par chenille (m/s) avec boost
	var left_target  = (left_input * max_forward_speed if left_input >= 0.0 else left_input * max_reverse_speed) * speed_multiplier
	var right_target = (right_input * max_forward_speed if right_input >= 0.0 else right_input * max_reverse_speed) * speed_multiplier

	# --- 4) Smoothing optionnel (réponse immédiate si use_smoothing=false)
	if use_smoothing:
		left_speed  = move_toward(left_speed, left_target, accel * delta)
		right_speed = move_toward(right_speed, right_target, accel * delta)
	else:
		left_speed = left_target
		right_speed = right_target

	# --- 5) Kinematics differential drive
	var v = (right_speed + left_speed) * 0.5               # vitesse linéaire du centre (m/s)
	var omega = (right_speed - left_speed) / track_width   # rad/s (yaw)

	# rotation autour de Y
	rotate_y(omega * delta)

	# direction avant locale (-Z)
	var forward_dir: Vector3 = -transform.basis.z.normalized()
	var target_velocity = forward_dir * v

	# damping si idle et smoothing activé
	if use_smoothing and abs(left_input) < 0.01 and abs(right_input) < 0.01:
		target_velocity = target_velocity.lerp(Vector3.ZERO, clamp(linear_damping * delta, 0, 1))

	# appliquer gravité sur y si besoin
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z
	velocity.y = velocity.y - ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	# déplacer et gérer collisions
	move_and_slide()


func handle_boost(delta: float) -> void:
	# On utilise aussi l'action dynamique pour le boost
	var boost_action = "p%d_boost" % player_id

	if Input.is_action_pressed(boost_action) and boost_time_remaining > 0.0 and boost_recharge_timer <= 0.0:
		is_boosting = true
		# ... (le reste de la fonction handle_boost reste identique) ...
		boost_time_remaining -= delta
		if boost_time_remaining <= 0.0:
			boost_time_remaining = 0.0
			is_boosting = false
			was_fully_depleted = true
			boost_recharge_timer = boost_recharge_delay
	else:
		is_boosting = false
	
	if boost_recharge_timer > 0.0:
		boost_recharge_timer -= delta
		if boost_recharge_timer <= 0.0:
			boost_recharge_timer = 0.0
			was_fully_depleted = false
			boost_time_remaining = boost_max_duration
	elif not is_boosting and boost_time_remaining < boost_max_duration and not was_fully_depleted:
		boost_time_remaining += boost_partial_recharge_rate * delta
		boost_time_remaining = min(boost_time_remaining, boost_max_duration)
		
func add_gold(amount: int) -> void:
	gold += amount
	
func take_damage(amount: int) -> void:
	self.health -= amount
	if health <= 0:
		die()

func die() -> void:
	emit_signal("died", player_id)
	visible = false
