extends Node2D

signal shoot
signal tower_sold
signal level_up

@export var FIRE_COOLDOWN = 1.0
@export var INFO_TIME_COOLDOWN = 0.6
@export var HOVER_TIME_COOLDOWN = 0.001

const BOUNDS_HOVERING_RADIUS = 48.0
const BOUNDS_NORMAL_RADIUS = 32.0

# === setting === #
var is_tower_built = false
var is_playing = false
var tower_type
var tile_coords = Vector2.ZERO

# === interaction === #
var _has_open_menu = false
var is_show_info_panel = false
var is_mouse_on_tower = false
var out_of_bounds_timer = Timer.new()
var hover_on_tower_timer = Timer.new()

# === fire === #
var fire_cooldown_timer = Timer.new()
var weapon_loaded = true
var any_target_in_range = false
var target_array = []

# === xp === #
#var temp_points = 0
#var point_coef = 0.2
var level = 1
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
		
		$Range/CollisionShape2D.shape.radius = 0.5 * GameData.tower_data[tower_type]["range"]
		shoot.connect($"../../Arrows".create_arrow)
		tower_sold.connect(Callable(get_parent().get_parent(),"on_tower_sold").bind(tile_coords))

func _process(_delta: float) -> void:
	if is_tower_built:
		if not get_parent().any_tower_has_open_menu(self):
			show_menu()
		
		check_level()

func check_level():
	prints(level,xp)
	if xp >= GameData.levels_xp[level-1].y:
		level_up.emit()
		level += 1

func _physics_process(_delta: float) -> void:
	if any_target_in_range and is_tower_built:
		turn_tower()
		if weapon_loaded:
			var target = select_target()
			var direction_to_target = position.direction_to(target.global_position)
			if is_playing:
				shoot.emit(direction_to_target,position,self)
				weapon_loaded = false
				fire_cooldown_timer.start(FIRE_COOLDOWN)
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

func _on_range_area_entered(area: Area2D) -> void:
	if is_tower_built:
		if area.get_parent().has_method("enemy") and area not in target_array:
			target_array.append(area)
		if target_array.size() > 0:
			any_target_in_range = true

func _on_range_area_exited(area: Area2D) -> void:
	if area.get_parent().has_method("enemy"):
		target_array.erase(area)
	if target_array.size() < 1:
		any_target_in_range = false

func _on_bounds_mouse_entered() -> void:
	# todo make timer for hovering
	if is_tower_built:
		hover_on_tower_timer.start(HOVER_TIME_COOLDOWN)
	get_node("Bounds/CollisionShape2D").shape.radius = BOUNDS_HOVERING_RADIUS
	out_of_bounds_timer.stop()


func _on_bounds_mouse_exited() -> void:
	hover_on_tower_timer.stop()
	get_node("Bounds/CollisionShape2D").shape.radius = BOUNDS_NORMAL_RADIUS
	if is_tower_built:
		is_mouse_on_tower = false
		out_of_bounds_timer.start(get_time_info_cooldown())

func _on_hover_on_tower_timeout():
	if is_tower_built:
		is_mouse_on_tower = true
		is_show_info_panel = true

func _on_out_of_bounds_timeout():
	is_show_info_panel = false

func _on_up_pressed():
	$UpMenu.visible = true
	$Bounds.visible = false
	is_mouse_on_tower = false
	is_show_info_panel = false

func _on_sell_pressed():
	$SellDialog.visible = true
	$Bounds.visible = false
	is_mouse_on_tower = false
	is_show_info_panel = false

func _on_dialog_ok_pressed() -> void:
	tower_sold.emit()
	await G.timer(0.4)
	call_deferred("queue_free")

func _on_dialog_cancel_pressed() -> void:
	$SellDialog.visible = false
	await G.timer(0.4)
	$Bounds.visible = true

func get_time_info_cooldown():
	return INFO_TIME_COOLDOWN * Engine.get_time_scale()
