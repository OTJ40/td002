extends CanvasLayer


func set_tower_preview(tower_type, mouse_position):
	var path = "res://scenes/towers/" + tower_type + ".tscn"
	#print(path)
	var drag_tower_instance = load(path).instantiate()
	drag_tower_instance.set_name("DragTower")
	drag_tower_instance.modulate = Color("47ff0ef3")
	
	var range_texture = Sprite2D.new()
	range_texture.set_name("Range")
	range_texture.position = Vector2.ZERO
	var scaling = GameData.tower_data[tower_type]["range"] / 600.0
	range_texture.scale = Vector2(scaling,scaling)
	var _texture = load("res://assets/range_overlay.png")
	range_texture.texture = _texture
	range_texture.modulate = Color("0bffff8d")
	
	var control = Control.new()
	control.add_child(drag_tower_instance,true)
	control.add_child(range_texture,true)
	control.position = mouse_position
	control.set_name("TowerPreview")
	add_child(control,true)
	move_child(control,0)

func update_tower_preview(new_position, color):
	get_node("TowerPreview").position = new_position
	if get_node("TowerPreview/DragTower").modulate != Color(color):
		get_node("TowerPreview/DragTower").modulate = Color(color)


func _on_pause_play_pressed() -> void:
	if get_parent().is_build_mode:
		get_parent().cancel_build_mode()
	if Engine.get_time_scale() == 0.001:
		Engine.set_time_scale(1.0)
		G.is_game_slowed = false
	elif get_parent().current_wave == 0:
		$HUD/Footer/MarginContainer2/HBoxContainer/FastForward.disabled = false
		#get_parent().current_wave += 1
		get_parent().start_next_wave()
	else:
		Engine.set_time_scale(0.001)
		G.is_game_slowed = true
		
	#if get_tree().is_paused():
		#get_tree().set_pause(false)
	#elif get_parent().current_wave == 0:
		#get_parent().current_wave += 1
		#get_parent().start_next_wave()
	#else:
		#get_tree().set_pause(true)

func update_next_wave_info(wave):
	wave += 1
	$HUD/Header/MarginContainer2/Panel/WaveInfoLabel.text = \
	"Next Wave: " + str(wave) + " assailants"

func update_current_info(num,total):
	$HUD/Header/MarginContainer3/Panel/CurrentWaveInfoLabel.text = "Current Wave: "+str(num)+"/"+str(total)

func update_health(health):
	#print(health)
	$HUD/Header/MarginContainer/ProgressBar.value = health

func _on_fast_forward_pressed() -> void:
	G.is_game_slowed = false
	$HUD/Footer/MarginContainer2/HBoxContainer/PausePlay.button_pressed = true
	if get_parent().is_build_mode:
		get_parent().cancel_build_mode()
	if Engine.get_time_scale() == 3.0:
		Engine.set_time_scale(1.0)
	else:
		Engine.set_time_scale(3.0)