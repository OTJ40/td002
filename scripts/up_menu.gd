extends Control

signal info_hover
#signal _cancel_pressed
signal damage_pressed
signal rate_pressed
signal range_pressed
signal speed_pressed

var tower

func _ready() -> void:
	tower = get_parent()
	#_cancel_pressed.connect(Callable(get_parent(),"_on_cancel_pressed"))
	damage_pressed.connect(Callable(get_parent(),"_on_damage_pressed"))
	rate_pressed.connect(Callable(get_parent(),"_on_rate_pressed"))
	range_pressed.connect(Callable(get_parent(),"_on_range_pressed"))
	speed_pressed.connect(Callable(get_parent(),"_on_speed_pressed"))
	var game_scene = get_tree().get_nodes_in_group("game_scene")[0]
	info_hover.connect(Callable(game_scene,"_on_info_hover"))

func _on_up_damage_pressed() -> void:
	damage_pressed.emit()

func _on_up_rate_pressed() -> void:
	rate_pressed.emit()

func _on_up_range_pressed() -> void:
	range_pressed.emit()

func _on_up_speed_pressed() -> void:
	speed_pressed.emit()

#func _on_cancel_pressed() -> void:
	#_cancel_pressed.emit()

func _on_up_damage_mouse_entered() -> void:
	var text = "Upgrade damage to " + str(tower.get_node("Data").damage*1.1) + " from " + str(tower.get_node("Data").damage)
	info_hover.emit(text)

func _on_up_damage_mouse_exited() -> void:
	info_hover.emit("")

func _on_up_range_mouse_entered() -> void:
	info_hover.emit("Upgrade range")

func _on_up_range_mouse_exited() -> void:
	info_hover.emit("")

func _on_up_rate_mouse_entered() -> void:
	info_hover.emit("Upgrade rate")

func _on_up_rate_mouse_exited() -> void:
	info_hover.emit("")

func _on_up_speed_mouse_entered() -> void:
	info_hover.emit("Upgrade speed")

func _on_up_speed_mouse_exited() -> void:
	info_hover.emit("")
