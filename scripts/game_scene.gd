extends Node2D

signal game_finished

const CANCEL_TIME_COOLDOWN = 0.4
# todo 1 - game balance, 2 - improve infotower readability, 3 - , 4 - round ups
@export var TIME_BETWEEN_WAVES = 2.5
#@export var TOWER_COST = 50.0
@export var map_node: PackedScene
#@export var health = 100

# === money === #
var t = 0
var money = 90.0
var money_factor = 1.0
var money_stop = false
var moneypool_level = 0
var tower_cost
var tower_cost_increase = 5
var progress_bar_ls

# === setting === #
var map_instance
var current_wave = 0
var current_wave_finished = false
var bailiffs_on_field_array = []

# === building === #
var is_tower_menu_mode = false
var is_build_mode = false
var is_build_valid = false
var build_location
var build_type
var build_tile

func _ready() -> void:
	progress_bar_ls = LabelSettings.new()
	tower_cost = GameData.tower_data["ArrowTower"]["first_cost"]
	G.is_game_slowed = true
	Engine.set_time_scale(0.001)
	get_node("UI").update_health(money,GameData.moneypools[moneypool_level])
	get_node("UI").update_next_wave_info(current_wave)
	
	game_finished.connect(Callable(get_parent(),"_on_game_finished"))

	set_map()
	
	# === todo in future: several types of buildings === #
	for build_button in get_tree().get_nodes_in_group("build_buttons"):
		build_button.pressed.connect(start_build_mode.bind(build_button.name))

func check_moneypool():
	if money > GameData.moneypools[moneypool_level]:
		moneypool_level += 1
		money_factor += 0.1
		$UI/HUD/HeaderRight/MarginContainer/FactorLabel.text = str(money_factor)

func check_factor():
	progress_bar_ls.font_color =\
	Color.BLACK if money/GameData.moneypools[moneypool_level] > 0.5 else Color.WHITE
	$UI/HUD/HeaderRight/MarginContainer/FactorLabel.set("label_settings",progress_bar_ls) 

func _physics_process(delta: float) -> void:
	#print(money/GameData.moneypools[moneypool_level])
	check_moneypool()
	t += 1
	if t == 6:
		check_factor()
		get_node("UI").update_health(money,GameData.moneypools[moneypool_level])
		t = 0
	if not G.is_game_slowed and not money_stop:
		money += delta * money_factor
	#prints(money,moneypool_level,money_factor,t)

func _process(_delta: float) -> void:
	#prints(tower_cost,$UI/HUD/FooterRight/HBoxContainer/PausePlay.is_pressed())
	if bailiffs_on_field_array.size() <= 0 and current_wave_finished and current_wave > 0:
		$UI/HUD/HeaderLeft/MarginContainer3/WaveProgress.reset_wave_progress()
		start_next_wave()
	
	if is_build_mode:
		update_tower_preview()
		stop_show_menus_in_build_mode()
	
	tower_menu_mode()
	check_prices()

func _unhandled_input(event: InputEvent) -> void:
	#print(event)
	if is_build_mode:
		if event.is_action_released("left_click"):
			verify_and_build()
			cancel_build_mode()
		if event.is_action_released("right_click"):
			cancel_build_mode()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("new_tower") and not is_tower_menu_mode:
		start_build_mode("ArrowTower")

#-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
#-===-===-===-build functions-===-===-===-===-===-===-===-
#-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
func cancel_build_mode():
	is_build_valid = false
	is_build_mode = false
	get_node("UI/TowerPreview").free()
	await G.timer(G.get_time_cooldown(CANCEL_TIME_COOLDOWN))
	start_show_menus()

func verify_and_build():
	if is_build_valid:
		if money >= tower_cost:
			var new_tower_instance = load("res://scenes/towers/" + build_type + ".tscn").instantiate()
			new_tower_instance.position = build_location
			new_tower_instance.is_tower_built = true
			new_tower_instance.tower_type = build_type
			new_tower_instance.tile_coords = build_tile
			get_node("Towers").add_child(new_tower_instance,true)
			map_instance.get_node("Exclusions").set_cell(0,build_tile,3,Vector2(0,0))
			# buying tower
			money -= tower_cost
			tower_cost += tower_cost_increase
			tower_cost_increase += 5
			$UI/HUD/FooterLeft/HBoxContainer/PriceLabel.text = str(tower_cost) + " coins(next +" + str(tower_cost_increase) + ")"

func stop_show_menus_in_build_mode():
	var towers = get_node("Towers").get_children()
	for twr in towers:
		twr.get_node("Bounds").visible = false

func start_build_mode(tower_type: String):
	if is_build_mode:
		cancel_build_mode()
	is_build_mode = true
	build_type = tower_type
	get_node("UI").set_tower_preview(tower_type,get_global_mouse_position())

func update_tower_preview():
	var mouse_position = get_global_mouse_position()
	var exclusions = map_instance.get_node("Exclusions")
	var current_tile = exclusions.local_to_map(mouse_position)
	var current_tile_position = exclusions.map_to_local(current_tile)
	if exclusions.get_cell_source_id(0,current_tile) == -1:
		get_node("UI").update_tower_preview(current_tile_position,"47ff0ef3")
		is_build_valid = true
		build_location = current_tile_position
		build_tile = current_tile
	else:
		get_node("UI").update_tower_preview(current_tile_position,"ff1524d4")
		is_build_valid = false

#-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
#-===-===-===-wave functions -===-===-===-===-===-===-===-
#-===-===-===-===-===-===-===-===-===-===-===-===-===-===-
func start_next_wave():
	current_wave_finished = false
	current_wave += 1
	var wave_data = GameData.get_wave_data(current_wave)
	await G.timer(TIME_BETWEEN_WAVES)
	spawn_enemies(wave_data)

func spawn_enemies(wave_data):
	var current_info_bailiffs = 0
	get_node("UI").update_next_wave_info(current_wave)
	
	for item in wave_data:
		var next_monster_name = item[0]
		var next_monster_time = item[1]
		
		var new_bailiff_instance \
		= load("res://scenes/enemies/" + next_monster_name + ".tscn").instantiate()
		
		new_bailiff_instance.base_damage.connect(Callable(self,"on_base_damage"))
		new_bailiff_instance.bailiff_death.connect(Callable(self,"bailiff_death"))
		new_bailiff_instance.bailiff_resource.hp += current_wave-1
		new_bailiff_instance.bailiff_resource.speed += (current_wave-1)*0.5
		
		bailiffs_on_field_array.append(new_bailiff_instance)
		var path_array = map_instance.get_node("Paths").get_children()
		path_array[randi() % path_array.size()].add_child(new_bailiff_instance,true)
		current_info_bailiffs += 1
		get_node("UI").update_current_info(current_info_bailiffs,current_wave)
		$UI/HUD/HeaderLeft/MarginContainer3/WaveProgress.new_bailiff_on_field(next_monster_time,current_wave)
		await G.timer(next_monster_time)
	current_wave_finished = true

func bailiff_death(bailiff):
	bailiffs_on_field_array.erase(bailiff)

func on_base_damage(damage,bailiff):
	bailiffs_on_field_array.erase(bailiff)
	money -= damage
	if money <= 0:
		money_stop = true
		G.game_speed(0.2)
		arrows_off()
		towers_off()
		await G.timer(G.get_time_cooldown(1))
		game_finished.emit()
		queue_free()
	else:
		get_node("UI").update_health(money,GameData.moneypools[moneypool_level])

func arrows_off():
	var arrows = $Arrows.get_children()
	for arw in arrows:
		arw.get_node("Hitbox").disabled = true

func towers_off():
	var towers = $Towers.get_children()
	for twr in towers:
		twr.is_playing = false

func on_tower_sold(_tile_coords):
	map_instance.get_node("Exclusions").erase_cell(0,_tile_coords)

func _on_info_hover(_text_array):
	if _text_array[0] == "":
		for i in $UI/HUD/HeaderLeft/Container/HBoxContainer.get_children():
			$UI/HUD/HeaderLeft/Container/HBoxContainer.remove_child(i)
	
	for i in _text_array.size():
		var l = Label.new()
		var ls = LabelSettings.new()
		if i % 2 == 0:
			ls = load("res://assets/themes/btn_lbl_settings.tres")
		else:
			if i == _text_array.size()-1:
				ls = load("res://assets/themes/lbl_settings_red.tres")
			else:
				ls = load("res://assets/themes/lbl_settings_blue.tres")
				
		l.label_settings = ls
		l.text = _text_array[i]
		$UI/HUD/HeaderLeft/Container/HBoxContainer.add_child(l)
	
	#var l = Label.new()
	#l.label_settings = load("res://assets/themes/btn_lbl_settings.tres")
	#l.text = "     " + _text_array[0] # + "    "
	#$UI/HUD/HeaderLeft/Container/HBoxContainer.add_child(l)
	#var tween = get_tree().create_tween().bind_node(l)
	#tween.tween_property(l,"size",Vector2(l.size.x,36),0.3)
		

func check_prices():
	for i in get_tree().get_nodes_in_group("money_cover"):
		if money < tower_cost:
			i.visible = true
		else:
			i.visible = false

func tower_menu_mode():
	for i in get_tree().get_nodes_in_group("menu_cover"):
		i.visible = is_tower_menu_mode

func start_show_menus():
	var towers = get_node("Towers").get_children()
	for twr in towers:
		twr.get_node("Bounds").visible = true

func on_has_open_dialogs():
	is_tower_menu_mode = true

func on_all_dialogs_closed():
	is_tower_menu_mode = false

func set_map():
	map_instance = map_node.instantiate()
	add_child(map_instance)
	move_child(map_instance,0)
