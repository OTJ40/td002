extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.





func _on_settings_mouse_entered() -> void:
	G.button_tween_entered($sdrj/VBoxContainer/Settings/Label,0.85)


func _on_settings_mouse_exited() -> void:
	G.button_tween_exited($sdrj/VBoxContainer/Settings/Label)


func _on_exit_to_main_mouse_entered() -> void:
	G.button_tween_entered($sdrj/VBoxContainer/ExitToMain/Label,0.85)


func _on_exit_to_main_mouse_exited() -> void:
	G.button_tween_exited($sdrj/VBoxContainer/ExitToMain/Label)


func _on_return_to_game_mouse_entered() -> void:
	G.button_tween_entered($sdrj/VBoxContainer/ReturnToGame/Label,0.85)


func _on_return_to_game_mouse_exited() -> void:
	G.button_tween_exited($sdrj/VBoxContainer/ReturnToGame/Label)


func _on_return_to_game_pressed() -> void:
	# todo fix label color
	await G.timer(G.get_time_cooldown(0.3))
	self.visible = false
	G.is_game_slowed = false
	G.game_speed(1.0)
