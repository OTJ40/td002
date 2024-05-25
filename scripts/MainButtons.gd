extends MarginContainer


func _on_new_game_mouse_entered() -> void:
	G.button_tween_entered($VBoxContainer/NewGame/Label,0.85)

func _on_new_game_mouse_exited() -> void:
	G.button_tween_exited($VBoxContainer/NewGame/Label)


func _on_exit_mouse_entered() -> void:
	G.button_tween_entered($VBoxContainer/Exit/Label,0.85)

func _on_exit_mouse_exited() -> void:
	G.button_tween_exited($VBoxContainer/Exit/Label)


func _on_load_game_mouse_entered() -> void:
	G.button_tween_entered($VBoxContainer/LoadGame/Label,0.85)

func _on_load_game_mouse_exited() -> void:
	G.button_tween_exited($VBoxContainer/LoadGame/Label)


func _on_settings_mouse_entered() -> void:
	G.button_tween_entered($VBoxContainer/Settings/Label,0.85)

func _on_settings_mouse_exited() -> void:
	G.button_tween_exited($VBoxContainer/Settings/Label)

