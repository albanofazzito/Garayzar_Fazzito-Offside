class_name Slot
extends Panel

var carta_actual: Carta = null
@export var tipo: JugadorData.Posicion
@export var columna: int = 0

func liberar() -> void:
	carta_actual =null
