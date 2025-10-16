class_name Bonus
extends Area3D

@export var coin_value: int = 25

func _ready() -> void:
	# connecte le signal body_entered à ta fonction locale
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is Tank :
		body.call("add_gold",coin_value)
		queue_free()
