extends Node

var damage
var rate
var t_range

func _ready() -> void:
	if get_parent().is_tower_built:
		damage = GameData.tower_data["ArrowTower"]["damage"]
		rate = GameData.tower_data["ArrowTower"]["rate"]
		t_range = GameData.tower_data["ArrowTower"]["range"]

