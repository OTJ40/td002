extends Node2D

signal shoot
signal tower_sold
signal level_up


var FIRE_COOLDOWN = 1.0
@export var INFO_TIME_COOLDOWN = 0.4
@export var HOVER_TIME_COOLDOWN = 0.1

const BOUNDS_HOVERING_RADIUS = 56.0
const BOUNDS_NORMAL_RADIUS = 32.0

# === setting === #
var is_tower_built = false
var is_playing = false
var tower_type
var tile_coords = Vector2.ZERO

# === interaction === #
var _has_open_menu = false
var _has_open_dialog = false
var is_show_info_panel = false
var is_mouse_on_tower = false
var out_of_bounds_timer = Timer.new()
var hover_on_tower_timer = Timer.new()

# === fire === #
var fire_cooldown_timer = Timer.new()
var weapon_loaded = true
var any_target_in_reach = false
var target_array = []

# === xp === #
#var temp_points = 0
#var point_coef = 0.2
var level = 1
var levels_to_upgrade = 0
var xp = 0
var kills = 0
#var hits = 0


func _ready() -> void:
	
	$Label.text = str(xp)
	$Skins/Bow.visible = true
	if is_tower_built:
		is_playing = true
		
		out_of_bounds_timer.timeout.connect(_on_out_of_bounds_timeout)
		out_of_bounds_timer.one_shot = true
		add_child(out_of_bounds_timer)
		
		fire_cooldown_timer.timeout.connect(_on_fire_timer_cooldown)
		fire_cooldown_timer.one_shot = true
		add_child(fire_cooldown_timer)
		
		hover_on_tower_timer.timeout.connect(_on_hover_on_tower_timeout)
		hover_on_tower_timer.one_shot = true
		add_child(hover_on_tower_timer)
		
		$Reach/CollisionShape2D.shape.radius = $TowerData.reach # GameData.tower_data[tower_type]["reach"]
		shoot.connect($"../../Arrows".create_arrow)
		tower_sold.connect(Callable(get_parent().get_parent(),"on_tower_sold").bind(tile_coords))
		retrieve_info()

func retrieve_info():
	var text = "damage = %s%s%s%s" % [str(snappedf($TowerData.damage,0.01)),"(",str(GameData.tower_data["ArrowTower"]["damage"]),")"]
	text += "\n"+"rate = %s%s%s%s" % [str(snappedf($TowerData.rate,0.01)),"(",str(GameData.tower_data["ArrowTower"]["rate"]),")"]
	text += "\n"+"reach = %s%s%s%s" % [str(snappedf($TowerData.reach,0.01)),"(",str(GameData.tower_data["ArrowTower"]["reach"]),")"]
	text += "\n"+"speed = %s%s%s%s" % [str(snappedf($TowerData.speed,0.01)),"(",str(GameData.tower_data["ArrowTower"]["speed"]),")"]
	text += "\n"+"level = %s%s%s%s" % [str(level),"(",str(levels_to_upgrade),")"]
	$Info.set_label(text)

func _process(_delta: float) -> void:
	
	#print(levels_to_upgrade)
	if is_tower_built:
		if not get_parent().any_tower_has_open_menu(self):
			show_menu()
		
		check_level()
		check_upgrade_possibility()

func check_upgrade_possibility():
	if levels_to_upgrade > 0:
		$UpgradeHalo.visible = true
		$Skins/Base.modulate = Color.RED
	else:
		$UpgradeHalo.visible = false
		$Skins/Base.modulate = Color("ffffff")

func check_level():
	if xp >= GameData.levels_xp[level-1].y:
		level_up.emit()
		level += 1
		levels_to_upgrade += 1
		retrieve_info()

func _physics_process(_delta: float) -> void:
	if any_target_in_reach and is_tower_built:
		turn_tower()
		if weapon_loaded:
			var target = select_targe()
			var direction_to_target = position.direction_to(target.global_position)
			if is_playing:
				shoot.emit(direction_to_target,position,self)
				weapon_loaded = false
				fire_cooldown_timer.start($TowerData.rate)
		else:
			$Skins/Bow.visible = false
			$Skins/BowLoosen.visible = true

func show_menu():
	if  is_mouse_on_tower or is_show_info_panel:
		$TowerMenu.visible = true
		_has_open_menu = true
	else:
		$TowerMenu.visible = false
		_has_open_menu = false

func select_targe():
	var target_hp_array = []
	for t in target_array:
		target_hp_array.append(t.get_parent().bailiff_data.hp)
	var min_hp = target_hp_array.min()
	var target_index = target_hp_array.find(min_hp)
	return target_array[target_index]

func select_target():
	var target_progress_array = []
	for t in target_array:
		target_progress_array.append(t.get_parent().progress)
	var max_progress = target_progress_array.max()
	var target_index = target_progress_array.find(max_progress)
	return target_array[target_index]

func turn_tower():
	var target_pos = select_target().global_position
	$Skins/Bow.look_at(target_pos)
	$Skins/BowLoosen.look_at(target_pos)

func _on_fire_timer_cooldown() -> void:
	if fire_cooldown_timer.is_stopped():
		weapon_loaded = true
		$Skins/Bow.visible = true
		$Skins/BowLoosen.visible = false

func add_points(_points,_kills):
	xp += _points
	kills += _kills
	$Label.text = str(xp)+" "+str(level)

func _on_reach_area_entered(area: Area2D) -> void:
	if is_tower_built:
		if area.get_parent().has_method("enemy") and area not in target_array:
			target_array.append(area)
		if target_array.size() > 0:
			any_target_in_reach = true

func _on_reach_area_exited(area: Area2D) -> void:
	if area.get_parent().has_method("enemy"):
		target_array.erase(area)
	if target_array.size() < 1:
		any_target_in_reach = false

func _on_bounds_mouse_entered() -> void:
	if is_tower_built and not _has_open_dialog:
		hover_on_tower_timer.start(G.get_scaled_time(HOVER_TIME_COOLDOWN))
	get_node("Bounds/CollisionShape2D").shape.radius = BOUNDS_HOVERING_RADIUS
	out_of_bounds_timer.stop()

func _on_bounds_mouse_exited() -> void:
	hover_on_tower_timer.stop()
	get_node("Bounds/CollisionShape2D").shape.radius = BOUNDS_NORMAL_RADIUS
	if is_tower_built:
		is_mouse_on_tower = false
		out_of_bounds_timer.start(G.get_scaled_time(INFO_TIME_COOLDOWN))

func _on_hover_on_tower_timeout():
	if is_tower_built:
		is_mouse_on_tower = true
		is_show_info_panel = true

func _on_out_of_bounds_timeout():
	is_show_info_panel = false

func _on_options_pressed():
	_has_open_dialog = true
	$Bounds.visible = false
	is_mouse_on_tower = false
	is_show_info_panel = false
	$OptionsMenu.visible = true

func _on_target_priority_pressed():
	pass

func _on_up_pressed():
	if levels_to_upgrade > 0:
		_has_open_dialog = true
		$Bounds.visible = false
		is_mouse_on_tower = false
		is_show_info_panel = false
		$UpMenu.visible = true

func _on_sell_pressed():
	_has_open_dialog = true
	$SellDialog.visible = true
	$Bounds.visible = false
	is_mouse_on_tower = false
	is_show_info_panel = false

func _on_damage_pressed():
	if levels_to_upgrade > 0:
		$TowerData.damage *= GameData.tower_data["ArrowTower"]["upgrade_factor"]["damage"]
		levels_to_upgrade -= 1
	_on_cancel_pressed()

func _on_rate_pressed():
	if levels_to_upgrade > 0:
		$TowerData.rate *= GameData.tower_data["ArrowTower"]["upgrade_factor"]["rate"]
		levels_to_upgrade -= 1
	_on_cancel_pressed()

func _on_reach_pressed():
	if levels_to_upgrade > 0:
		$TowerData.reach *= GameData.tower_data["ArrowTower"]["upgrade_factor"]["reach"]
		get_node("Reach/CollisionShape2D").shape.radius = $TowerData.reach
		#$Reach/CollisionShape2D.shape.radius = $Data.reach
		levels_to_upgrade -= 1
	_on_cancel_pressed()

func _on_speed_pressed():
	if levels_to_upgrade > 0:
		$TowerData.speed *= GameData.tower_data["ArrowTower"]["upgrade_factor"]["speed"]
		levels_to_upgrade -= 1
	_on_cancel_pressed()

func _on_info_pressed():
	retrieve_info()
	_has_open_dialog = true
	$Info.visible = true
	$Bounds.visible = false
	is_mouse_on_tower = false
	is_show_info_panel = false

func _on_dialog_ok_pressed() -> void:
	_has_open_dialog = false
	tower_sold.emit()
	await G.timer(G.get_scaled_time(INFO_TIME_COOLDOWN))
	call_deferred("queue_free")

func _on_cancel_pressed() -> void:
	await G.timer(G.get_scaled_time(INFO_TIME_COOLDOWN))
	_has_open_dialog = false
	$SellDialog.visible = false
	$UpMenu.visible = false
	$Info.visible = false
	$Bounds.visible = true





