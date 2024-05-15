extends Node2D

signal to_main_menu

func _ready() -> void:
	to_main_menu.connect(Callable(get_parent(),"_load_main_menu"))
	await G.timer(5)
	to_main_menu.emit()
	queue_free()
