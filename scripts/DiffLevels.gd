extends PanelContainer

func _on_easy_mouse_entered() -> void:
	G.button_tween_entered($MarginContainer/VBoxContainer/Easy/Label,0.85)

func _on_easy_mouse_exited() -> void:
	G.button_tween_exited($MarginContainer/VBoxContainer/Easy/Label)

func _on_medium_mouse_entered() -> void:
	G.button_tween_entered($MarginContainer/VBoxContainer/Medium/Label,0.85)

func _on_medium_mouse_exited() -> void:
	G.button_tween_exited($MarginContainer/VBoxContainer/Medium/Label)

func _on_hard_mouse_entered() -> void:
	G.button_tween_entered($MarginContainer/VBoxContainer/Hard/Label,0.85)

func _on_hard_mouse_exited() -> void:
	G.button_tween_exited($MarginContainer/VBoxContainer/Hard/Label)
