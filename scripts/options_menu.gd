extends Control

signal info_hover
signal target_priority_pressed

func _ready() -> void:
	var game_scene = get_tree().get_nodes_in_group("game_scene")[0]
	target_priority_pressed.connect(Callable(get_parent(),"_on_target_priority_pressed"))
	info_hover.connect(Callable(game_scene,"_on_info_hover"))

func _on_target_priority_pressed() -> void:
	target_priority_pressed.emit()

func _on_target_priority_mouse_entered() -> void:
	var text = [
		"   target_priority  "
	]
	info_hover.emit(text)


func _on_target_priority_mouse_exited() -> void:
	info_hover.emit([""])


