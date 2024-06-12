extends PanelContainer

signal to_main_menu

var game_scene

func _ready() -> void:
	material.set_shader_parameter("mix_amount",0.0)
	game_scene = get_tree().get_nodes_in_group("game_scene")[0]
	to_main_menu.connect(Callable(game_scene.get_parent(),"_load_main_menu"))

func _on_settings_mouse_entered() -> void:
	G.button_tween_entered($Container/VBoxContainer/Settings/Label,0.85)

func _on_settings_mouse_exited() -> void:
	G.button_tween_exited($Container/VBoxContainer/Settings/Label)

func _on_exit_to_main_mouse_entered() -> void:
	G.button_tween_entered($Container/VBoxContainer/ExitToMain/Label,0.85)

func _on_exit_to_main_mouse_exited() -> void:
	G.button_tween_exited($Container/VBoxContainer/ExitToMain/Label)

func _on_return_to_game_mouse_entered() -> void:
	G.button_tween_entered($Container/VBoxContainer/ReturnToGame/Label,0.85)

func _on_return_to_game_mouse_exited() -> void:
	G.button_tween_exited($Container/VBoxContainer/ReturnToGame/Label)

func _on_return_to_game_pressed() -> void:
	await G.timer(G.get_scaled_time(0.3))
	self.visible = false
	if game_scene.current_wave > 0:
		$"../FooterRight/HBoxContainer/PausePlay".set_pressed(true)
		$"../FooterRight"._is_pause_is_play_toggle(true,false)
		G.is_game_slowed = false
		G.game_speed(1.0)

func set_shader_value(value: float):
	material.set_shader_parameter("mix_amount",value)

func _on_exit_to_main_pressed() -> void:
	var tween = create_tween().bind_node(self)
	tween.tween_method(set_shader_value, 0.0, 1.0, G.get_scaled_time(1.0))
	await G.timer(G.get_scaled_time(1.2))
	tween.finished.connect(func(): tween.kill())
	to_main_menu.emit()
	game_scene.queue_free()
