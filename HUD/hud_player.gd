class_name HudPlayer
extends Node

@export 
var tank: Tank
@export 
var hud: HUD 

func _ready() -> void:
	tank.health_changed.connect(hud.update_health)
	tank.gold_changed.connect(hud.update_gold)
	hud.update_player_id(tank.player_id)
	hud.update_health(tank.health)
	hud.update_gold(tank.gold)
	
	hud.update_boost(tank.boost_time_remaining, tank.boost_max_duration, false)

func _process(_delta: float) -> void:
	if tank and hud:
		hud.update_boost(tank.boost_time_remaining, tank.boost_max_duration, tank.was_fully_depleted)
