extends Control


signal _ok_pressed
signal _cancel_pressed

func _ready() -> void:
	position = get_parent().global_position - Vector2(70,50)
	_ok_pressed.connect(Callable(get_parent(),"_on_dialog_ok_pressed"))
	_cancel_pressed.connect(Callable(get_parent(),"_on_dialog_cancel_pressed"))


func _on_ok_pressed() -> void:
	_ok_pressed.emit()


func _on_cancel_pressed() -> void:
	_cancel_pressed.emit()
