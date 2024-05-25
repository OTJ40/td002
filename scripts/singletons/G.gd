extends Node

var is_game_slowed: bool

func get_time_cooldown(time):
	return time * Engine.get_time_scale()

func game_speed(factor):
	Engine.set_time_scale(factor)

func timer(time):
	await get_tree().create_timer(time).timeout

func button_tween_entered(node: Node,scale: float):
	var tween = create_tween().bind_node(node)
	tween.tween_property\
	(node,"scale",Vector2(scale,scale),G.get_time_cooldown(0.1))
	tween.tween_property\
	(node,"modulate",Color("f6dc52e5"),G.get_time_cooldown(0.05))
	await G.timer(G.get_time_cooldown(0.25))
	tween.kill()

func button_tween_exited(node: Node):
	var tween = create_tween().bind_node(node)
	tween.tween_property\
	(node,"scale",Vector2(1.0,1.0),G.get_time_cooldown(0.1))
	tween.tween_property\
	(node,"modulate",Color("ffffff"),G.get_time_cooldown(0.1))
	await G.timer(G.get_time_cooldown(0.25))
	tween.kill()
