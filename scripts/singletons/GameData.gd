extends Node

const ENEMY_TYPE = "Bailiff"

var tower_data = {
	"ArrowTower": {
		"damage": 80,
		"rate": 1,
		"range": 125,
	},
}

var levels_xp = []

func set_levels_xp(base_xp,exponent):
	var level = 1
	var xp = 0
	for i in range(1,27):
		xp = round(pow((level),exponent)*base_xp)
		level += 1
		levels_xp.append(Vector2i(level,xp))
	print(levels_xp)

func get_wave_data(wave_num):
	randomize()
	var data_array = []
	for i in range(0,wave_num):
		var spawn_time = randf_range(0.5,1.5)
		data_array.append([ENEMY_TYPE,spawn_time])
	return data_array

