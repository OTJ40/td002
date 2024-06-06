extends Area2D

class_name Arrow

var SPEED
var DAMAGE

var tower
var arrow_texture
var direction = Vector2.ZERO
var life_timer = Timer.new()

func _ready() -> void:
	DAMAGE = tower.get_node("Data").damage
	SPEED = tower.get_node("Data").speed
	arrow_texture = load("res://assets/arrow_01.png")
	life_timer.timeout.connect(_arrow_destruction)
	life_timer.wait_time = 1.5
	life_timer.one_shot = true
	life_timer.autostart = true
	add_child(life_timer)

func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		position += SPEED * direction * delta

func _arrow_destruction():
	$Hitbox.set_deferred("disabled",true)
	queue_free()

func set_direction(dir):
	direction = dir
	set_rotation(dir.angle())

func _on_area_entered(area: Area2D) -> void:
	#print(area.get_parent())
	if area.get_parent().has_method("enemy"):
		#tower.add_points()
		_arrow_destruction()
		_arrow_duplication(area)

func _arrow_duplication(injury: Area2D):
	var dupl = Sprite2D.new()
	var dt = Timer.new()
	dt.timeout.connect(func(): dupl.queue_free())
	dt.autostart = true
	dt.wait_time = 3.0
	dupl.add_child(dt)
	dupl.texture = arrow_texture
	dupl.scale = Vector2(0.7,0.7)
	dupl.rotation = direction.angle()
	dupl.modulate = Color.RED
	injury.get_parent().get_node("Dupls").add_child(dupl)
	dupl.position = injury.global_position
	dupl.set_as_top_level(true)
	var tween = get_tree().create_tween().bind_node(dupl)
	tween.tween_property(dupl,"modulate",Color(0,0,0,0),2.5)
	tween.finished.connect(func(): tween.kill())

func on_hit(points,kills):
	tower.add_points(points,kills)
