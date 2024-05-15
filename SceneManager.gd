extends Node

func _ready() -> void:
	_load_main_menu()

func _load_main_menu():
	var main_menu = load("res://scenes/main_menu.tscn").instantiate()
	add_child(main_menu)
	

func _on_game_finished():
	var death_splash_screen = load("res://scenes/death_splash.tscn").instantiate()
	Engine.set_time_scale(1.0)
	G.game_speed(1.0)
	add_child(death_splash_screen)

func _on_game_started():
	var new_game = load("res://scenes/game_scene.tscn").instantiate()
	new_game.modulate = Color("ffffff00")
	var tween = create_tween()
	add_child(new_game)
	tween.tween_property(new_game,"modulate",Color("ffffff"),0.7)
