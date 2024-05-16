extends Control

signal up_pressed
signal sell_pressed

func _ready() -> void:
	position = get_parent().position - Vector2(70,50)
	up_pressed.connect(Callable(get_parent(),"_on_up_pressed"))
	sell_pressed.connect(Callable(get_parent(),"_on_sell_pressed"))

func _on_up_pressed() -> void:
	up_pressed.emit()

func _on_sell_pressed() -> void:
	sell_pressed.emit()
