extends Control

signal target_priority_ok_pressed

var target_priority_choice: int

func _ready() -> void:
	target_priority_ok_pressed.connect(Callable(get_parent(),"_on_target_priority_chosen"))

func _on_ok_pressed() -> void:
	if target_priority_choice > 0:
		target_priority_ok_pressed.emit(target_priority_choice)

func _on_nearest_to_base_toggled(toggled_on: bool) -> void:
	if toggled_on:
		target_priority_choice = get_parent().TARGET_PRIORITY.NEAREST_TO_BASE

func _on_least_hp_toggled(toggled_on: bool) -> void:
	if toggled_on:
		target_priority_choice = get_parent().TARGET_PRIORITY.LEAST_HP

func _on_random_toggled(toggled_on: bool) -> void:
	if toggled_on:
		target_priority_choice = get_parent().TARGET_PRIORITY.RANDOM

func _on_boss_toggled(toggled_on: bool) -> void:
	if toggled_on:
		target_priority_choice = get_parent().TARGET_PRIORITY.BOSS
