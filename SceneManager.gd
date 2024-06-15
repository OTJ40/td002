extends Node

@export var MAIN_MENU: PackedScene
@export var DEATH_SPLASH_SCREEN: PackedScene
@export var GAME_SCENE: PackedScene

var base_xp: float
@export var exponent: float = 1.4 # 1.45

func _ready() -> void:
	#var f1 = 0.965
	#var f2 = 0.97
	#var l1 = 1.0
	#var l2 = 1.0
	#
	#for i in 30:
		#prints(l1,l2)
		#l1 *= f1
		#l2 *= f2
	_load_main_menu()

func _load_main_menu():
	GameData.levels_xp = []
	var main_menu = MAIN_MENU.instantiate()
	add_child(main_menu)
	

func _on_game_finished():
	var death_splash_screen = DEATH_SPLASH_SCREEN.instantiate()
	G.game_speed(1.0)
	add_child(death_splash_screen)

func _on_game_started(difficulty: String):
	var new_game = GAME_SCENE.instantiate()
	match difficulty:
		"easy":
			base_xp = 11.0
		"medium":
			base_xp = 13.0
		"hard":
			base_xp = 15.0
	GameData.bailiff_pillage_factor =\
		GameData._set_bailiff_pillage_factor(difficulty)
	GameData.set_levels_xp(base_xp,exponent)
	new_game.modulate = Color("ffffff00")
	add_child(new_game)
	
