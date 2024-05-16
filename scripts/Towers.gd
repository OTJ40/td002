extends Node2D

func _process(_delta: float) -> void:
	pass

func any_tower_has_open_menu(excluded_tower):
	var all_towers = get_children()
	if all_towers.has(excluded_tower):
		all_towers.erase(excluded_tower)
	for twr in all_towers:
		if twr != excluded_tower:
			if twr._has_open_menu:
				return true
	return false

#func _get_all_towers():
	#return get_children()
