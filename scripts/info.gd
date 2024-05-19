extends Control

signal exit_info

@onready var lbl: Label = $MarginContainer/Label

func _ready() -> void:
	position = get_parent().position - Vector2(72,72)
	exit_info.connect(Callable(get_parent(),"_on_cancel_pressed"))

func set_label(_text):
	lbl.text = _text

func _on_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			exit_info.emit()
