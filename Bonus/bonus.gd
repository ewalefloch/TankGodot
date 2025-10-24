# Bonus.gd
class_name Bonus
extends Area3D

@export var mesh_main: MeshInstance3D     # modèle visible
@export var mesh_glow: MeshInstance3D     # second mesh optionnel (ex: effet)


func _ready() -> void:
	# connecte body_entered au callback
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# on ne prend que les tanks
	if body is Tank:
		apply_to(body)
		queue_free()

func apply_to(tank: Node) -> void:
	# override this in derived classes
	push_warning("Bonus.apply_to not implemented")
