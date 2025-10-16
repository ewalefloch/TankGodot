class_name CoinSpawner
extends Node3D
# coin_spawner.gd

@export_group("Spawn Settings")
@export var bonus_scene: PackedScene  # Glisse ta scène bonus.tscn ici
@export var number_of_coins: int = 20  # Nombre de pièces à spawner
@export var spawn_height: float = 0.5  # Hauteur par rapport au sol

@export_group("Spawn Area")
@export var spawn_area_size: Vector2 = Vector2(50, 50)  # Taille de la zone (X, Z)
@export var spawn_center: Vector3 = Vector3.ZERO  # Centre de la zone de spawn

@export_group("Advanced")
@export var min_distance_between_coins: float = 2.0  # Distance minimale entre pièces
@export var max_spawn_attempts: int = 50  # Tentatives max par pièce

func _ready() -> void:
	spawn_coins()

func spawn_coins() -> void:
	if bonus_scene == null:
		push_error("Bonus scene not assigned in CoinSpawner!")
		return
	
	var spawned_positions: Array[Vector3] = []
	var coins_spawned: int = 0
	
	for i in range(number_of_coins):
		var positionGold = find_valid_spawn_position(spawned_positions)
		
		if positionGold != Vector3.ZERO:
			var coin = bonus_scene.instantiate()
			add_child(coin)
			coin.global_position = positionGold
			spawned_positions.append(positionGold)
			coins_spawned += 1
		else:
			push_warning("Could not find valid position for coin %d" % i)
	
	print("Spawned %d / %d coins" % [coins_spawned, number_of_coins])

func find_valid_spawn_position(existing_positions: Array[Vector3]) -> Vector3:
	for attempt in range(max_spawn_attempts):
		# Générer position aléatoire dans la zone
		var random_x = randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2)
		var random_z = randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
		
		var test_position = spawn_center + Vector3(random_x, spawn_height, random_z)
		
		# Vérifier si la position est valide (pas trop proche d'autres pièces)
		if is_position_valid(test_position, existing_positions):
			return test_position
	
	# Si aucune position valide trouvée après max_spawn_attempts
	return Vector3.ZERO

func is_position_valid(positionGold: Vector3, existing_positions: Array[Vector3]) -> bool:
	for existing_pos in existing_positions:
		var distance = positionGold.distance_to(existing_pos)
		if distance < min_distance_between_coins:
			return false
	return true
