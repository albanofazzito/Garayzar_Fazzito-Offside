extends Control

const SiguienteNivel = "res://Escenas/Nivel.tscn"
const Menu = "res://Escenas/Menu.tscn"

func _on_button_pressed() -> void:
	Transicion.cambiar_escena(Menu)


func _on_button_2_pressed() -> void:
	Global.escenario_actual= Global.Escenario.SEMIS
	Transicion.cambiar_escena(SiguienteNivel)
