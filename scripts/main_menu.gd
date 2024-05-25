extends Node2D

signal new_game
var t = 0
var flip_bailiff = true

func _ready() -> void:
	$MarginContainer.mouse_filter = Control.MOUSE_FILTER_STOP
	#menu_tweener("start") # todo - closed for editing
	$MarginContainer.mouse_filter = Control.MOUSE_FILTER_PASS
	new_game.connect(Callable(get_parent(),"_on_game_started"))

func _process(_delta: float) -> void:
	t += 1
	if t == 13:
		$MarginContainer/HBoxContainer/TextureRect.flip_v = flip_bailiff
		flip_bailiff = !flip_bailiff
		t = 0

func menu_tweener(word: String):
	var bg = $MarginContainer/BG
	var btn_container = $MarginContainer/HBoxContainer/MainButtons/VBoxContainer
	var tween = create_tween()
	match word:
		"start":
			bg.modulate = Color("ffffff00")
			position = Vector2(-1600,0)
			btn_container.modulate = Color("ffffff00")
			tween.tween_property(self,"position",Vector2(0,0),1.5)
			tween.tween_property(bg,"modulate",Color("ffffff"),0.4)
			tween.set_parallel(true)
			tween.tween_property(btn_container,"modulate",Color("ffffff"),0.4)
		"finish":
			tween.set_parallel(true)
			tween.tween_property(btn_container,"modulate",Color("ffffff00"),0.5)
			tween.tween_property(bg,"modulate",Color("ffffff00"),0.5)
			tween.set_parallel(false)
			tween.tween_property(self,"modulate",Color("ffffff00"),1.5)
			tween.set_parallel(true)
			tween.tween_property(self,"position",Vector2(1600,0),1.5)

func _on_new_game_pressed() -> void:
	#menu_tweener("finish") # todo - closed for editing
	#await G.timer(1.8)
	new_game.emit()
	queue_free()

func _on_load_game_pressed() -> void:
	pass # Replace with function body.

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	menu_tweener("finish")
	await G.timer(2.0)
	get_tree().quit(0)
