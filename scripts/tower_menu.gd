extends Control


signal info_hover
signal up_pressed
signal sell_pressed
signal info_pressed



func _ready() -> void:
	var game_scene = get_tree().get_nodes_in_group("game_scene")[0]
	position = get_parent().position - Vector2(72,72)
	up_pressed.connect(Callable(get_parent(),"_on_up_pressed"))
	sell_pressed.connect(Callable(get_parent(),"_on_sell_pressed"))
	info_pressed.connect(Callable(get_parent(),"_on_info_pressed"))
	info_hover.connect(Callable(game_scene,"_on_info_hover"))

func _on_up_pressed() -> void:
	up_pressed.emit()

func _on_sell_pressed() -> void:
	sell_pressed.emit()

func _on_info_pressed() -> void:
	info_pressed.emit()

func _on_up_mouse_entered() -> void:
	info_hover.emit(["   Upgrade tower   "])

func _on_up_mouse_exited() -> void:
	info_hover.emit([""])

func _on_sell_mouse_entered() -> void:
	info_hover.emit(["   Sell tower   "])

func _on_sell_mouse_exited() -> void:
	info_hover.emit([""])

func _on_info_mouse_entered() -> void:
	var text = ["   Info tower   "]
	info_hover.emit(text)

func _on_info_mouse_exited() -> void:
	info_hover.emit([""])
