extends Node

const ENEMY_TYPE = "Bailiff"

var tower_data = {
	"ArrowTower": {
		"damage": 30,
		"rate": 1,
		"range": 250,
	},
}


func get_wave_data(wave_num):
	randomize()
	var data_array = []
	for i in range(0,wave_num):
		var spawn_time = randf_range(0.5,1.5)
		data_array.append([ENEMY_TYPE,spawn_time])
	return data_array

