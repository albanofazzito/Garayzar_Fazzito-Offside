class_name Slot
extends Panel

var carta_actual: Carta = null
@export var tipo: JugadorData.Posicion
@export var columna: int = 0

func get_drop_rect() -> Rect2:
	var r = get_global_rect()
	var expand_x = r.size.x * 0.4
	var expand_y = 80.0
	return Rect2(r.position.x - expand_x, r.position.y - expand_y, r.size.x + expand_x * 2.0, r.size.y + expand_y * 2.0)

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
