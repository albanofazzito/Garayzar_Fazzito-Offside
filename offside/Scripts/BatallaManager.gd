class_name BatallaManager
extends Node

signal batalla_terminada

@export var vida_enemigo: VidaBase
@export var vida_jugador: VidaBase

func iniciar_batalla() -> void:
	_inicializar_cartas()
	_aplicar_efectos_turno()
	var vida_j_antes =vida_jugador.vida_actual if vida_jugador else 0
	var vida_e_antes =vida_enemigo.vida_actual if vida_enemigo else 0
	await get_tree().create_timer(0.4).timeout
	for col in range(5):
		await _resolver_columna(col)
	_check_rage(vida_j_antes, vida_e_antes)
	_resetear_inmunidad()
	batalla_terminada.emit()

func _resetear_inmunidad() -> void:
	if vida_jugador:
		vida_jugador.inmune = false
	if vida_enemigo:
		vida_enemigo.inmune = false

func _inicializar_cartas() -> void:
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.carta_actual:
			slot.carta_actual.inicializar_combate()
	for slot in get_tree().get_nodes_in_group("slots_enemigo"):
		if slot.carta_actual:
			slot.carta_actual.inicializar_combate()

func _aplicar_efectos_turno() -> void:
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.carta_actual:
			slot.carta_actual.aplicar_efecto_turno()
	for slot in get_tree().get_nodes_in_group("slots_enemigo"):
		if slot.carta_actual:
			slot.carta_actual.aplicar_efecto_turno()

func _check_rage(vida_j_antes: int, vida_e_antes: int) -> void:
	if vida_jugador and vida_jugador.vida_actual <vida_j_antes:
		for slot in get_tree().get_nodes_in_group("slots"):
			if slot.carta_actual:
				slot.carta_actual.activar_rage(vida_jugador.vida_actual)
	if vida_enemigo and vida_enemigo.vida_actual <vida_e_antes:
		for slot in get_tree().get_nodes_in_group("slots_enemigo"):
			if slot.carta_actual:
				slot.carta_actual.activar_rage(vida_enemigo.vida_actual)

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
			if !carta_e.puede_esquivar():
				carta_e.recibir_danio(carta_j.datos.stat_ataque)
			await get_tree().create_timer(0.25).timeout
			await carta_e.animar_ataque(carta_j)
			if !carta_j.puede_esquivar():
				carta_j.recibir_danio(carta_e.datos.stat_ataque)
			await get_tree().create_timer(0.25).timeout
		else:
			await carta_e.animar_ataque(carta_j)
			if !carta_j.puede_esquivar():
				carta_j.recibir_danio(carta_e.datos.stat_ataque)
			await get_tree().create_timer(0.25).timeout
			await carta_j.animar_ataque(carta_e)
			if !carta_e.puede_esquivar():
				carta_e.recibir_danio(carta_j.datos.stat_ataque)
			await get_tree().create_timer(0.25).timeout
	elif carta_j and !carta_e:
		if vida_enemigo:
			await carta_j.animar_ataque_base()
			vida_enemigo.recibir_danio(carta_j.datos.stat_ataque)
			await get_tree().create_timer(0.25).timeout
	elif carta_e and !carta_j:
		if vida_jugador:
			await carta_e.animar_ataque_base()
			vida_jugador.recibir_danio(carta_e.datos.stat_ataque)
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
	slot.mostrar_visual()
	if carta.tween_color:
		carta.tween_color.kill()
	var tw =carta.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(carta, "scale", Vector2(0.72, 0.48), 0.08)
	tw.parallel().tween_property(carta, "modulate", Color(0.5, 0.5, 0.5), 0.08)
	tw.tween_property(carta, "scale", Vector2(0.0, 0.0), 0.25)
	tw.parallel().tween_property(carta, "rotation", deg_to_rad(20.0), 0.25)
	tw.parallel().tween_property(carta, "modulate:a", 0.0, 0.2)
	await tw.finished
	carta.queue_free()

func _get_slot(col: int, grupo: String):
	for slot in get_tree().get_nodes_in_group(grupo):
		if slot.columna ==col:
			return slot
	return null
