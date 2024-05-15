extends Node2D

@export var arrow_scene: PackedScene

func create_arrow(direction_to_target,_position,_tower):
	var arrow = arrow_scene.instantiate()
	arrow.position = _position
	arrow.tower = _tower
	arrow.set_direction(direction_to_target)
	add_child(arrow)
