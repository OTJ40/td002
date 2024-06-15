extends Node

const ENEMY_TYPE = "Bailiff"

var tower_data = {
	"ArrowTower": {
		"damage": 30,
		"rate": 1.0,
		"reach": 125,
		"speed": 600,
		"first_cost": 50,
		"upgrade_factor":{
			"damage": 1.03,
			"rate": 0.965,
			"reach": 1.03,
			"speed": 1.03,
		}
	},
}

var levels_xp = []
var moneypools = [120.0,160.0,210.0,280.0,370.0,490.0,650.0,870.0] # /0.75
var bailiff_pillage_factor 

func _set_bailiff_pillage_factor(difficulty: String):
	match difficulty:
		"easy":
			return 8.0
		"medium":
			return 9.0
		"hard":
			return 10.0

func set_levels_xp(base_xp,exponent):
	var level = 1
	var xp = 0
	for i in range(1,67):
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

