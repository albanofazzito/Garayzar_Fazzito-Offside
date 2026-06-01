class_name BatallaManager
extends Node

signal batalla_terminada

func iniciar_batalla() -> void:
	_inicializar_cartas()
	await get_tree().create_timer(0.4).timeout
	for col in range(5):
		await _resolver_columna(col)
	batalla_terminada.emit()

func _inicializar_cartas() -> void:
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.carta_actual:
			slot.carta_actual.inicializar_combate()
	for slot in get_tree().get_nodes_in_group("slots_enemigo"):
		if slot.carta_actual:
			slot.carta_actual.inicializar_combate()

func _resolver_columna(col: int) -> void:
	var slot_j =_get_slot(col, "slots")
	var slot_e =_get_slot(col, "slots_enemigo")
	var carta_j =slot_j.carta_actual if slot_j else null
	var carta_e =slot_e.carta_actual if slot_e else null

	if carta_j ==null and carta_e ==null:
		return

	if carta_j and carta_e:
		if carta_j.datos.stat_velocidad >= carta_e.datos.stat_velocidad:
			await carta_j.animar_ataque(carta_e)
			carta_e.recibir_danio(carta_j.datos.stat_ataque)
			await get_tree().create_timer(0.25).timeout
			await carta_e.animar_ataque(carta_j)
			carta_j.recibir_danio(carta_e.datos.stat_ataque)
			await get_tree().create_timer(0.25).timeout
		else:
			await carta_e.animar_ataque(carta_j)
			carta_j.recibir_danio(carta_e.datos.stat_ataque)
			await get_tree().create_timer(0.25).timeout
			await carta_j.animar_ataque(carta_e)
			carta_e.recibir_danio(carta_j.datos.stat_ataque)
			await get_tree().create_timer(0.25).timeout

	await get_tree().create_timer(0.35).timeout
	await _limpiar_muertos(slot_j, slot_e)

func _limpiar_muertos(slot_j, slot_e) -> void:
	if slot_j and slot_j.carta_actual and !slot_j.carta_actual.esta_viva():
		await _eliminar_carta(slot_j)
	if slot_e and slot_e.carta_actual and !slot_e.carta_actual.esta_viva():
		await _eliminar_carta(slot_e)

func _eliminar_carta(slot) -> void:
	var carta =slot.carta_actual
	slot.carta_actual =null
	if carta.tween_color:
		carta.tween_color.kill()
	var tw =carta.create_tween()
	tw.tween_property(carta, "modulate:a", 0.0, 0.3)
	await tw.finished
	carta.queue_free()

func _get_slot(col: int, grupo: String):
	for slot in get_tree().get_nodes_in_group(grupo):
		if slot.columna ==col:
			return slot
	return null
