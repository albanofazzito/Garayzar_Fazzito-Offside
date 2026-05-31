extends Control

const Menu = "res://Escenas/Menu.tscn"

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(Menu)
