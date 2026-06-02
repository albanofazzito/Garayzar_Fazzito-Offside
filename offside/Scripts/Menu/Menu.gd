extends Control

const SiguienteNivel = "res://Escenas/Nivel.tscn"
const Menu = "res://Escenas/Menu.tscn"

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(Menu)


func _on_button_2_pressed() -> void:
	Global.escenario_actual= Global.Escenario.TUTORIAL
	get_tree().change_scene_to_file(SiguienteNivel)
