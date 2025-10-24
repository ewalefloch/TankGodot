# BonusSpawner.gd
extends Node3D

## Configuration des bonus
@export_group("Bonus Scenes")
@export var bonus_soins_scene: PackedScene
@export var bonus_boost_scene: PackedScene
@export var bonus_bouclier_scene: PackedScene

## Configuration du spawn
@export_group("Spawn Settings")
@export var spawn_interval: float = 20.0
@export var spawn_at_start: bool = true
@export var spawn_radius: float = 20.0  # Rayon autour du spawner
@export var min_distance_from_center: float = 5.0  # Distance minimale du centre
@export var spawn_height: float = 0.5  # Hauteur du spawn au-dessus du sol
@export var max_spawn_height: float = 2.0  # Hauteur maximale autorisée pour spawn (Y max)

## Détection de collision
@export_group("Collision Detection")
@export var check_collisions: bool = true
@export var collision_check_radius: float = 2.0  # Rayon de vérification (pour éviter les immeubles/arbres)
@export var raycast_height: float = 20.0  # Hauteur du raycast
@export var ground_collision_mask: int = 1  # Masque pour détecter le sol (layer du sol)
@export var obstacle_collision_mask: int = 3  # Masque pour détecter obstacles (immeubles = layer 2)

var active_bonuses: Array[Node] = []
var spawn_timer: Timer
var can_spawn: bool = true
var space_state: PhysicsDirectSpaceState3D

func _ready() -> void:
	# Récupérer le PhysicsDirectSpaceState3D
	space_state = get_world_3d().direct_space_state
	
	# Configuration du timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# Spawn initial si activé (en deferred pour éviter les erreurs)
	if spawn_at_start:
		spawn_random_bonus.call_deferred()
	
	# Démarrer le timer
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	# Vérifier s'il n'y a plus de bonus actifs
	update_active_bonuses()
	
	# Spawner seulement s'il n'y a AUCUN bonus sur la map
	if active_bonuses.is_empty() and can_spawn:
		spawn_random_bonus()

func update_active_bonuses() -> void:
	# Nettoyer la liste des bonus qui n'existent plus
	active_bonuses = active_bonuses.filter(func(bonus): return is_instance_valid(bonus))

func spawn_random_bonus() -> void:
	var bonus_scenes = [bonus_soins_scene, bonus_boost_scene, bonus_bouclier_scene]
	
	# Filtrer les scènes nulles
	bonus_scenes = bonus_scenes.filter(func(scene): return scene != null)
	
	if bonus_scenes.is_empty():
		push_warning("Aucune scène de bonus n'est assignée!")
		return
	
	# Choisir un bonus aléatoire
	var selected_scene = bonus_scenes[randi() % bonus_scenes.size()]
	
	# Trouver une position valide
	var spawn_position = get_valid_spawn_position()
	
	if spawn_position == Vector3.ZERO:
		push_warning("Impossible de trouver une position de spawn valide")
		return
	
	# Instancier le bonus
	var bonus_instance = selected_scene.instantiate()
	bonus_instance.position = spawn_position
	get_parent().call_deferred("add_child", bonus_instance)
	
	# Attendre que le bonus soit dans l'arbre avant de set la position globale
	await get_tree().process_frame
	if is_instance_valid(bonus_instance):
		bonus_instance.global_position = spawn_position
	
	# Ajouter à la liste des bonus actifs
	active_bonuses.append(bonus_instance)
	
	# Connecter les signaux de suppression
	if bonus_instance.has_signal("collected"):
		bonus_instance.collected.connect(_on_bonus_collected.bind(bonus_instance))
	bonus_instance.tree_exiting.connect(_on_bonus_removed.bind(bonus_instance))
	
	print("Bonus spawné: ", selected_scene.resource_path.get_file(), " à ", spawn_position)

func get_valid_spawn_position() -> Vector3:
	var max_attempts = 100
	var attempt = 0
	
	while attempt < max_attempts:
		attempt += 1
		
		# Générer une position aléatoire dans le rayon (plan XZ)
		var angle = randf() * TAU
		var distance = randf_range(min_distance_from_center, spawn_radius)
		var offset = Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		var potential_position = global_position + offset
		
		# Ajuster la hauteur avec un raycast vers le sol
		potential_position.y = global_position.y + raycast_height
		var ground_position = find_ground_position(potential_position)
		
		if ground_position != Vector3.ZERO:
			ground_position.y += spawn_height  # Ajouter la hauteur de spawn
			
			# Vérifier que la position n'est pas trop haute
			if ground_position.y > max_spawn_height:
				continue  # Position trop haute, on passe à la tentative suivante
			
			# Vérifier si la position est valide (pas d'obstacle)
			if is_position_valid(ground_position):
				return ground_position
	
	return Vector3.ZERO

func find_ground_position(start_pos: Vector3) -> Vector3:
	if not space_state:
		return start_pos
	
	# Raycast vers le bas pour trouver le sol
	var query = PhysicsRayQueryParameters3D.create(
		start_pos,
		start_pos + Vector3.DOWN * (raycast_height * 2)
	)
	query.collision_mask = ground_collision_mask
	
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.position
	
	# Si pas de sol trouvé, retourner zéro (position invalide)
	return Vector3.ZERO

func is_position_valid(pos: Vector3) -> bool:
	if not check_collisions or not space_state:
		return true
	
	# Vérifier avec une sphère s'il y a des obstacles (immeubles, arbres)
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = SphereShape3D.new()
	shape.radius = collision_check_radius
	query.shape = shape
	query.transform = Transform3D(Basis(), pos)
	query.collision_mask = obstacle_collision_mask
	
	# Vérifier s'il y a des collisions
	var results = space_state.intersect_shape(query, 10)
	
	# Filtrer les collisions : ignorer le sol
	for result in results:
		var collider = result.collider
		# Si c'est un RigidBody3D (immeubles) ou StaticBody3D (arbres), c'est invalide
		if collider is RigidBody3D or (collider is StaticBody3D and collider.name != "Sol"):
			return false
	
	return true

func _on_bonus_collected(bonus: Node) -> void:
	if bonus in active_bonuses:
		active_bonuses.erase(bonus)

func _on_bonus_removed(bonus: Node) -> void:
	if bonus in active_bonuses:
		active_bonuses.erase(bonus)

## Forcer un spawn manuel
func force_spawn() -> void:
	spawn_random_bonus()

## Pause/Resume du spawning
func pause_spawning() -> void:
	can_spawn = false
	spawn_timer.stop()

func resume_spawning() -> void:
	can_spawn = true
	spawn_timer.start()
