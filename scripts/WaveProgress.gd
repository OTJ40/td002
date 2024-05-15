extends TextureProgressBar

var num = 0

func new_bailiff_on_field(time,wave):
	num += 1
	var tween = get_tree().create_tween().bind_node(self)
	var val = (num * 1.0 / wave) * 100
	tween.tween_property(self,"value",val,time).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(func(): tween.kill())

func reset_wave_progress():
	value = 0
	num = 0
