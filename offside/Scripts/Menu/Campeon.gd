extends Control

const Menu = "res://Escenas/Menu.tscn"

func _on_button_pressed() -> void:
	Transicion.cambiar_escena(Menu)
