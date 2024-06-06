extends Node

@export var MAIN_MENU: PackedScene
@export var DEATH_SPLASH_SCREEN: PackedScene
@export var GAME_SCENE: PackedScene

@export var base_xp: float = 15.0
@export var exponent: float = 1.4 # 1.45

func _ready() -> void:
	#print(snappedf(1/3.0,0.0001))
	GameData.set_levels_xp(base_xp,exponent)
	#GameData.set_levels_xp(base_xp,exponent-0.03)
	_load_main_menu()

func _load_main_menu():
	var main_menu = MAIN_MENU.instantiate()
	add_child(main_menu)
	

func _on_game_finished():
	var death_splash_screen = DEATH_SPLASH_SCREEN.instantiate()
	Engine.set_time_scale(1.0)
	G.game_speed(1.0)
	add_child(death_splash_screen)

func _on_game_started():
	var new_game = GAME_SCENE.instantiate()
	#new_game.modulate = Color("ffffff00")
	var tween = create_tween()
	add_child(new_game)
	tween.tween_property(new_game,"modulate",Color("ffffff"),0.7)
