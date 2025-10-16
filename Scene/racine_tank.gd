extends Node3D

@export 
var tank: Tank
@export 
var hud: HUD 

func _ready() -> void:
	tank.health_changed.connect(hud.update_health)
	tank.gold_changed.connect(hud.update_gold)
	
	hud.update_health(tank.health)
	hud.update_gold(tank.gold)
