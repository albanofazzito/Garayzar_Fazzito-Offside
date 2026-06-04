class_name Slot
extends Panel

var carta_actual: Carta = null
@export var tipo: JugadorData.Posicion
@export var columna: int = 0

func ocultar_visual() -> void:
	for child in get_children():
		child.visible = false
	self_modulate.a = 0.0

func mostrar_visual() -> void:
	for child in get_children():
		child.visible = true
	self_modulate.a = 1.0

func liberar() -> void:
	carta_actual = null
	mostrar_visual()
