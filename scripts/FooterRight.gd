extends MarginContainer

signal info_hover

var game_scene

func _ready() -> void:
	game_scene = get_tree().get_nodes_in_group("game_scene")[0]
	info_hover.connect(Callable(game_scene,"_on_info_hover"))

func _on_menu_mouse_entered() -> void:
	G.button_tween_entered($HBoxContainer/Menu/Label,0.85)
	info_hover.emit(["   Menu Button   "])

func _on_menu_mouse_exited() -> void:
	G.button_tween_exited($HBoxContainer/Menu/Label)
	info_hover.emit([""])

func _on_pause_play_mouse_entered() -> void:
	if G.is_game_slowed:
		G.button_tween_entered($HBoxContainer/PausePlay/Play,0.7)
		info_hover.emit(["   Press To Play   "])
	else :
		info_hover.emit(["   Press To Pause   "])

func _on_pause_play_mouse_exited() -> void:
	$HBoxContainer/PausePlay/GoldenPlay.visible = false
	if G.is_game_slowed:
		G.button_tween_exited($HBoxContainer/PausePlay/Play)
	info_hover.emit([""])

func _on_pause_play_pressed() -> void:
	if game_scene.is_build_mode:
		game_scene.cancel_build_mode()
	if game_scene.current_wave == 0:
		_is_pause_is_play_toggle(true,false)
		G.is_game_slowed = false
		Engine.set_time_scale(1.0)
		$HBoxContainer/FastForward.disabled = false
		game_scene.start_next_wave()
	elif Engine.get_time_scale() == 0.0001:
		#play
		$HBoxContainer/PausePlay/GoldenPlay.visible = false
		_is_pause_is_play_toggle(true,false)
		G.is_game_slowed = false
		Engine.set_time_scale(1.0)
	else:
		# pause
		$HBoxContainer/PausePlay/Play.scale = Vector2(0.7,0.7)
		if Engine.get_time_scale() == 2.0:
			$HBoxContainer/PausePlay/GoldenPlay.visible = true
		_is_pause_is_play_toggle(false,true)
		G.is_game_slowed = true
		Engine.set_time_scale(0.0001)

func _on_pause_play_button_up() -> void:
	#print(G.is_game_slowed)
	if G.is_game_slowed:
		$HBoxContainer/PausePlay/GoldenPlay.visible = true
		info_hover.emit([""])
		info_hover.emit(["   Press To Play   "])
	else:
		info_hover.emit([""])
		info_hover.emit(["   Press To Pause   "])

func _on_fast_forward_pressed() -> void:
	G.is_game_slowed = false
	$HBoxContainer/PausePlay.button_pressed = true
	if game_scene.is_build_mode:
		game_scene.cancel_build_mode()
	if Engine.get_time_scale() == 2.0:
		G.game_speed(1.0)
	else:
		_is_pause_is_play_toggle(true,false)
		G.game_speed(2.0)

func _on_fast_forward_mouse_entered() -> void:
	if not $HBoxContainer/FastForward.disabled:
		G.button_tween_entered($HBoxContainer/FastForward/TextureRect,0.7)
		if Engine.get_time_scale() == 2.0:
			info_hover.emit(["   Press To NormalSpeed   "])
		else:
			info_hover.emit(["   Press To FastForward   "])

func _on_fast_forward_mouse_exited() -> void:
	G.button_tween_exited($HBoxContainer/FastForward/TextureRect)
	info_hover.emit([""])

func _on_fast_forward_button_up() -> void:
	if Engine.get_time_scale() == 2.0:
		info_hover.emit([""])
		info_hover.emit(["   Press To NormalSpeed   "])
	else:
		info_hover.emit([""])
		info_hover.emit(["   Press To FastForward   "])

func _is_pause_is_play_toggle(is_pause: bool,is_play: bool):
	$HBoxContainer/PausePlay/Pause.visible = is_pause
	$HBoxContainer/PausePlay/Play.visible = is_play

func _on_menu_pressed() -> void:
	$"../CenterMenu".material.set_shader_parameter("mix_amount",0.4)
	$"../CenterMenu/Container/VBoxContainer/ReturnToGame/Label".modulate = Color("ffffff")
	$"../CenterMenu/Container/VBoxContainer/ReturnToGame/Label".scale = Vector2(1.0,1.0)
	$"../CenterMenu".visible = true
	if game_scene.current_wave > 0:
		_is_pause_is_play_toggle(true,false)
		G.is_game_slowed = true
		G.game_speed(0.0001)
