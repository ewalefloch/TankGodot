class_name HudPlayer
extends Node

@export 
var tank: Tank
@export 
var hud: HUD 

func _ready() -> void:
	tank.health_changed.connect(hud.update_health)
	hud.update_player_id(tank.player_id)
	hud.update_health(tank.health)
	hud.update_gold(tank.gold)
	hud.update_boost(tank.boost_time_remaining, tank.boost_max_duration, false)
	hud.update_bonus_boost(tank._boost_powerup_time,tank._boost_powerup_time_max,false)
	tank.bouclier_changed.connect(hud.update_bouclier)
	hud.update_bouclier(tank.shield_remaining)
	hud.updat_bonus_bouclier(tank._shield_time,tank._shield_time_max,false)

func _process(_delta: float) -> void:
	if tank and hud:
		hud.update_boost(tank.boost_time_remaining, tank.boost_max_duration, tank.was_fully_depleted)
		hud.update_bonus_boost(tank._boost_powerup_time,tank._boost_powerup_time_max,tank._boost_powerup_active)
		hud.updat_bonus_bouclier(tank._shield_time,tank._shield_time_max,tank._shield_active)
