extends Node2D

signal has_open_dialogs
signal all_dialogs_closed

func _ready() -> void:
	has_open_dialogs.connect(Callable(get_parent(),"on_has_open_dialogs"))
	all_dialogs_closed.connect(Callable(get_parent(),"on_all_dialogs_closed"))

func _process(_delta: float) -> void:
	if is_any_tower():
		has_open_dialogs.emit()
	else:
		all_dialogs_closed.emit()

func is_any_tower():
	var all_towers = get_children()
	for twr in all_towers:
		if twr._has_open_menu or twr._has_open_dialog:
			return true
	return false
	

func any_tower_has_open_menu(excluded_tower):
	var all_towers = get_children()
	if all_towers.has(excluded_tower):
		all_towers.erase(excluded_tower)
	for twr in all_towers:
		if twr != excluded_tower:
			if twr._has_open_menu or twr._has_open_dialog:
				return true
	return false

