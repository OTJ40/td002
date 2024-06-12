extends Node

var damage: float
var rate: float
var reach: float
var speed: float


func _ready() -> void:
	if get_parent().is_tower_built:
		damage = GameData.tower_data["ArrowTower"]["damage"]
		rate = GameData.tower_data["ArrowTower"]["rate"]
		reach = GameData.tower_data["ArrowTower"]["reach"]
		speed = GameData.tower_data["ArrowTower"]["speed"]

