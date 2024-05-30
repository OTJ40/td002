extends Control

signal info_hover
#signal _cancel_pressed
signal damage_pressed
signal rate_pressed
signal range_pressed
signal speed_pressed

var damage_factor
var range_factor
var rate_factor
var speed_factor
var tower

func _ready() -> void:
	tower = get_parent()
	#_cancel_pressed.connect(Callable(get_parent(),"_on_cancel_pressed"))
	damage_pressed.connect(Callable(get_parent(),"_on_damage_pressed"))
	rate_pressed.connect(Callable(get_parent(),"_on_rate_pressed"))
	range_pressed.connect(Callable(get_parent(),"_on_range_pressed"))
	speed_pressed.connect(Callable(get_parent(),"_on_speed_pressed"))
	var game_scene = get_tree().get_nodes_in_group("game_scene")[0]
	info_hover.connect(Callable(game_scene,"_on_info_hover"))
	
	damage_factor = GameData.tower_data["ArrowTower"]["upgrade_factor"]["damage"]
	range_factor = GameData.tower_data["ArrowTower"]["upgrade_factor"]["range"]
	rate_factor = GameData.tower_data["ArrowTower"]["upgrade_factor"]["rate"]
	speed_factor = GameData.tower_data["ArrowTower"]["upgrade_factor"]["speed"]

func _on_up_damage_pressed() -> void:
	damage_pressed.emit()

func _on_up_rate_pressed() -> void:
	rate_pressed.emit()

func _on_up_range_pressed() -> void:
	range_pressed.emit()

func _on_up_speed_pressed() -> void:
	speed_pressed.emit()

#func _on_cancel_pressed() -> void:
	#_cancel_pressed.emit()

func _on_up_damage_mouse_entered() -> void:
	var text = "Upgrade damage to " + str(tower.get_node("Data").damage*damage_factor) + " from " + str(tower.get_node("Data").damage)
	info_hover.emit(text)

func _on_up_damage_mouse_exited() -> void:
	info_hover.emit("")

func _on_up_range_mouse_entered() -> void:
	var text = "Upgrade range to " + str(tower.get_node("Data").t_range*range_factor) + " from " + str(tower.get_node("Data").t_range)
	info_hover.emit(text)

func _on_up_range_mouse_exited() -> void:
	info_hover.emit("")

func _on_up_rate_mouse_entered() -> void:
	var text = "Upgrade rate to " + str(tower.get_node("Data").rate*rate_factor) + " from " + str(tower.get_node("Data").rate)
	info_hover.emit(text)

func _on_up_rate_mouse_exited() -> void:
	info_hover.emit("")

func _on_up_speed_mouse_entered() -> void:
	var text = "Upgrade speed to " + str(tower.get_node("Data").speed*speed_factor) + " from " + str(tower.get_node("Data").speed)
	info_hover.emit(text)

func _on_up_speed_mouse_exited() -> void:
	info_hover.emit("")
