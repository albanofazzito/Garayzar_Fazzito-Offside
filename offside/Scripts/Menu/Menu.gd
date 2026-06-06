extends Control

const SiguienteNivel = "res://Escenas/Nivel.tscn"
const Menu = "res://Escenas/Menu.tscn"

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(Menu)

func _on_selector_pais_item_selected(index: int) -> void:
	Global.pais_jugador =index as JugadorData.Pais

func _on_button_2_pressed() -> void:
	Global.escenario_actual= Global.Escenario.TUTORIAL
	get_tree().change_scene_to_file(SiguienteNivel)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				Global.escenario_actual= Global.Escenario.TUTORIAL
				get_tree().change_scene_to_file(SiguienteNivel)
			KEY_2:
				Global.escenario_actual= Global.Escenario.CUARTOS
				get_tree().change_scene_to_file(SiguienteNivel)
			KEY_3:
				Global.escenario_actual= Global.Escenario.SEMIS
				get_tree().change_scene_to_file(SiguienteNivel)
			KEY_4:
				Global.escenario_actual= Global.Escenario.FINAL
				get_tree().change_scene_to_file(SiguienteNivel)
