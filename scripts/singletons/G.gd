extends Node

var is_game_slowed: bool

func get_time_cooldown(time):
	return time * Engine.get_time_scale()

func game_speed(factor):
	Engine.set_time_scale(factor)

func timer(time):
	await get_tree().create_timer(time).timeout
