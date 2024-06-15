extends PathFollow2D

signal info_hover
signal bailiff_death
signal base_damage

#@export var SPEED = 120
@export var bailiff_data: BailiffData
var hp_max

func _ready() -> void:
	hp_max = bailiff_data.hp
	var game_scene = get_tree().get_nodes_in_group("game_scene")[0]
	info_hover.connect(Callable(game_scene,"_on_info_hover"))
	$HP.max_value = bailiff_data.hp
	$HP.value = bailiff_data.hp

#func _process(_delta: float) -> void:
	#$Label.text = str(bailiff_resource.hp)+" "+str(bailiff_resource.speed)

func _physics_process(delta: float) -> void:
	if progress_ratio == 1.0:
		pillage_base()
	move(delta)

func pillage_base():
	#prints(bailiff_data.hp,hp_max)
	var pillage = (bailiff_data.hp/hp_max)*GameData.bailiff_pillage_factor
	base_damage.emit(pillage,self)
	queue_free()

func move(delta):
	$HP.position = position - Vector2(14,24)
	move_dupls()
	progress += bailiff_data.speed * delta

func move_dupls():
	if $Dupls.get_children().size() > 0:
		for i in $Dupls.get_children():
			i.position = position

func _on_hitbox_area_entered(arrow: Area2D) -> void:
	if arrow.has_method("on_hit"):
		arrow.queue_free()
		bailiff_data.hp -= arrow.DAMAGE
		$HP.value = bailiff_data.hp
		if bailiff_data.hp <= 0:
			bailiff_death.emit(self)
			arrow.on_hit(3,1)
			dying()
		else:
			arrow.on_hit(1,0)

func dying():
	$HP.visible = false
	$Hurtbox.call_deferred("free")
	$Skin.set_speed_scale(0.2)
	bailiff_data.speed = lerpf(bailiff_data.speed,0.0,0.8)
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(self,"modulate",Color(1,0,0,1.0),0.5)
	tween.tween_property(self,"modulate",Color(1,0,0,0.1),1.0)
	tween.finished.connect(func(): tween.kill())
	await G.timer(1.5)
	queue_free()

func enemy():
	pass

func _on_hurtbox_mouse_entered() -> void:
	var bailiff_hp_string = "%.1f" % bailiff_data.hp
	var text = [self.name+" - HP:  "+bailiff_hp_string+" / "+str(hp_max)\
	+"  SPEED:  "+str(bailiff_data.speed)+"   "]
	info_hover.emit(text)

func _on_hurtbox_mouse_exited() -> void:
	info_hover.emit([""])
