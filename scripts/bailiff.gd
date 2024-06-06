extends PathFollow2D

signal info_hover
signal bailiff_death
signal base_damage

#@export var SPEED = 120
@export var bailiff_resource: BailiffResource
var hp_max

func _ready() -> void:
	hp_max = bailiff_resource.hp
	var game_scene = get_tree().get_nodes_in_group("game_scene")[0]
	info_hover.connect(Callable(game_scene,"_on_info_hover"))
	$HP.max_value = bailiff_resource.hp
	$HP.value = bailiff_resource.hp

#func _process(_delta: float) -> void:
	#$Label.text = str(bailiff_resource.hp)+" "+str(bailiff_resource.speed)

func _physics_process(delta: float) -> void:
	if progress_ratio == 1.0:
		pillage_base()
	move(delta)

func pillage_base():
	base_damage.emit((bailiff_resource.hp/hp_max)*10.0,self)
	queue_free()

func move(delta):
	$HP.position = position - Vector2(14,24)
	move_dupls()
	progress += bailiff_resource.speed * delta

func move_dupls():
	if $Dupls.get_children().size() > 0:
		for i in $Dupls.get_children():
			i.position = position
			#i.rotation = rotation
	

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("on_hit"):
		bailiff_resource.hp -= area.DAMAGE
		$HP.value = bailiff_resource.hp
		if bailiff_resource.hp <= 0:
			bailiff_death.emit(self)
			area.on_hit(3,1)
			dying()
		else:
			area.on_hit(1,0)

func dying():
	$HP.visible = false
	$Hurtbox.call_deferred("free")
	$Skin.set_speed_scale(0.2)
	bailiff_resource.speed = lerpf(bailiff_resource.speed,0.0,0.8)
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(self,"modulate",Color(1,0,0,1.0),0.5)
	tween.tween_property(self,"modulate",Color(1,0,0,0.3),1.0)
	tween.finished.connect(func(): tween.kill())
	await G.timer(1.5)
	queue_free()

func enemy():
	pass

func _on_hurtbox_mouse_entered() -> void:
	var text = [self.name+" - HP: "+str(bailiff_resource.hp)+"/"+str(hp_max)+" SPEED: "+str(bailiff_resource.speed)+"   "]
	info_hover.emit(text)

func _on_hurtbox_mouse_exited() -> void:
	info_hover.emit([""])
