extends Control

signal _cancel_pressed
signal damage_pressed
signal rate_pressed

func _ready() -> void:
	_cancel_pressed.connect(Callable(get_parent(),"_on_cancel_pressed"))
	damage_pressed.connect(Callable(get_parent(),"_on_damage_pressed"))
	rate_pressed.connect(Callable(get_parent(),"_on_rate_pressed"))

func _on_cancel_pressed() -> void:
	_cancel_pressed.emit()

func _on_up_damage_pressed() -> void:
	damage_pressed.emit()

func _on_up_rate_pressed() -> void:
	rate_pressed.emit()
