extends Control

const SiguienteNivel = "res://Escenas/Nivel.tscn"


func _on_button_pressed() -> void:
	get_tree().quit()

func _on_button_2_pressed() -> void:
	Transicion.cambiar_escena("res://Escenas/SeleccionDT.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				Global.escenario_actual= Global.Escenario.TUTORIAL
				Transicion.cambiar_escena(SiguienteNivel)
			KEY_2:
				Global.escenario_actual= Global.Escenario.CUARTOS
				Transicion.cambiar_escena(SiguienteNivel)
			KEY_3:
				Global.escenario_actual= Global.Escenario.SEMIS
				Transicion.cambiar_escena(SiguienteNivel)
			KEY_4:
				Global.escenario_actual= Global.Escenario.FINAL
				Transicion.cambiar_escena(SiguienteNivel)
