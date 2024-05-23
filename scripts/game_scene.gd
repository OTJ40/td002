extends Node2D

signal game_finished

const CANCEL_TIME_COOLDOWN = 0.4
# todo 1 - moneypool
@export var TIME_BETWEEN_WAVES = 2.5
@export var map_node: PackedScene
@export var health = 100

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
	get_node("UI").update_health(health)
	get_node("UI").update_next_wave_info(current_wave)
	
	game_finished.connect(Callable(get_parent(),"_on_game_finished"))

	set_map()
	
	# === todo in future: several types of buildings === #
	for build_button in get_tree().get_nodes_in_group("build_buttons"):
		build_button.pressed.connect(start_build_mode.bind(build_button.name))

func _process(_delta: float) -> void:
	if bailiffs_on_field_array.size() <= 0 and current_wave_finished and current_wave > 0:
		$UI/HUD/HeaderLeft/MarginContainer3/WaveProgress.reset_wave_progress()
		start_next_wave()
	
	if is_build_mode:
		update_tower_preview()
		stop_show_menus_in_build_mode()
	
	tower_menu_mode()

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
		var new_tower_instance = load("res://scenes/towers/" + build_type + ".tscn").instantiate()
		new_tower_instance.position = build_location
		new_tower_instance.is_tower_built = true
		new_tower_instance.tower_type = build_type
		new_tower_instance.tile_coords = build_tile
		get_node("Towers").add_child(new_tower_instance,true)
		map_instance.get_node("Exclusions").set_cell(0,build_tile,3,Vector2(0,0))

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
	health -= damage
	if health <= 0:
		G.game_speed(0.2)
		arrows_off()
		towers_off()
		await G.timer(1)
		game_finished.emit()
		queue_free()
	else:
		get_node("UI").update_health(health)

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

func _on_info_hover(_text):
	var l = Label.new()
	l.label_settings = load("res://assets/themes/btn_lbl_settings.tres")
	l.text = "     " + _text + "    "
	$UI/HUD/HeaderLeft/Container.add_child(l)
	#var tween = get_tree().create_tween().bind_node(l)
	if _text == "":
		for i in $UI/HUD/HeaderLeft/Container.get_children():
			$UI/HUD/HeaderLeft/Container.remove_child(i)
	#tween.tween_property(l,"size",Vector2(l.size.x,36),0.3)
		

func tower_menu_mode():
	for i in get_tree().get_nodes_in_group("footer_cover"):
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
