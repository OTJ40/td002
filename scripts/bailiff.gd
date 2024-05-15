extends PathFollow2D

signal bailiff_death
signal base_damage

@export var SPEED = 120
@export var DAMAGE: float
#var damage = 10
var hp = 150

func _ready() -> void:
	$HP.max_value = hp
	$HP.value = hp


func _physics_process(delta: float) -> void:
	if progress_ratio == 1.0:
		base_damage.emit(hp/150.0,self)
		queue_free()
	move(delta)

func move(delta):
	$HP.position = position - Vector2(14,24)
	progress += SPEED * delta

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("on_hit"):
		hp -= area.DAMAGE
		$HP.value = hp
		if hp <= 0:
			bailiff_death.emit(self)
			area.on_hit(3,1)
			dying()
		else:
			area.on_hit(1,0)

func dying():
	$HP.visible = false
	$Hitbox.call_deferred("free")
	$Skin.set_speed_scale(0.25)
	SPEED = lerpf(SPEED,0.0,0.8)
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(self,"modulate",Color(1,0,0,1.0),0.5)
	tween.tween_property(self,"modulate",Color(1,0,0,0.3),1.0)
	tween.finished.connect(func(): tween.kill())
	await G.timer(1.5)
	#assailant_death.emit()
	queue_free()

func enemy():
	pass

